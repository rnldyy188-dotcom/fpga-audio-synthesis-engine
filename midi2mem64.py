import argparse
import math
from pathlib import Path

import mido

CLK_HZ = 100_000_000  # Your  clock
# 10 ms chosen because:
# - small enough to preserve rhythm accuracy
# - large enough to reduce memory footprint in FPGA BRAM
# - matches tone scheduler resolution in my Verilog player
TICK_SEC = 0.01


def midi_note_to_div(note: int, clk_hz: int = CLK_HZ) -> int:
    """MIDI note -> frequency divider for square wave toggling every note_div cycles."""
    # MIDI 69 = A4 = 440 Hz
    freq = 440.0 * (2.0 ** ((note - 69) / 12.0))
    div = int(round(clk_hz / (2.0 * freq)))
    if div < 1:
        div = 1
    return div


def choose_melody_top(active_notes):
    """Return highest active note (melody), or None."""
    if not active_notes:
        return None
    return max(active_notes)


def parse_midi_to_events(mid_path: Path, speed: float, prefer_track: int | None):
    """
    Return list of (note_or_none, dur_ticks_10ms)
    - melody chosen as highest active note across all tracks OR within one track.
    - uses tempo from MIDI (set_tempo), default 500000 us/qn.
    """
    mid = mido.MidiFile(str(mid_path))

   
    tempo = 500_000  
    ticks_per_beat = mid.ticks_per_beat
    merged = []
    for ti, track in enumerate(mid.tracks):
        abs_tick = 0
        for msg in track:
            abs_tick += msg.time
            if msg.type == "set_tempo":
                merged.append((abs_tick, "tempo", msg.tempo, ti))
            elif msg.type in ("note_on", "note_off"):
                merged.append((abs_tick, "note", msg, ti))
            

    merged.sort(key=lambda x: x[0])
    active = set()

    def tick_to_seconds(dt_ticks: int, tempo_us_per_beat: int) -> float:
        # seconds per tick = (tempo us/beat) / 1e6 / ticks_per_beat
        return (tempo_us_per_beat / 1e6) * (dt_ticks / ticks_per_beat)
  
    segments = []
    prev_tick = 0
    prev_note = None

    for abs_tick, kind, payload, track_id in merged:
        dt = abs_tick - prev_tick
        if dt > 0:
            dur_sec = tick_to_seconds(dt, tempo)
            dur_10ms = int(round((dur_sec / TICK_SEC) * speed))
            if dur_10ms < 1:
                dur_10ms = 1

            cur_note = choose_melody_top(active)
            # RLE merge
            if segments and segments[-1][0] == cur_note:
                segments[-1] = (cur_note, segments[-1][1] + dur_10ms)
            else:
                segments.append((cur_note, dur_10ms))

        if kind == "tempo":
            tempo = payload
        else:
            msg: mido.Message = payload
            if prefer_track is None or track_id == prefer_track:
                if msg.type == "note_on" and msg.velocity > 0:
                    active.add(msg.note)
                else:
                    active.discard(msg.note)

        prev_tick = abs_tick

    return segments


def write_mem64(segments, out_path: Path):
    """
    Write 64-bit hex lines:
      [63:32] div (8 hex)
      [31:16] dur (4 hex)
      [15:0]  cmd (4 hex)  -> END = FFFF
    """
    lines = []
    for note, dur in segments:
        div = 0 if note is None else midi_note_to_div(note)

        while dur > 0xFFFF:
            lines.append(f"{div:08X}{0xFFFF:04X}0000")
            dur -= 0xFFFF

        lines.append(f"{div:08X}{dur:04X}0000")

    # END marker
    lines.append(f"{0:08X}{0:04X}FFFF")
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("midi", type=str, help="input .mid file")
    ap.add_argument("-o", "--out", type=str, default="song.mem", help="output mem file")
    ap.add_argument("--speed", type=float, default=1.0, help="tempo multiplier (0.7 = faster)")
    ap.add_argument("--track", type=int, default=None, help="prefer melody from this track index (0-based)")
    args = ap.parse_args()

    midi_path = Path(args.midi)
    out_path = Path(args.out)

    segments = parse_midi_to_events(midi_path, speed=args.speed, prefer_track=args.track)
    write_mem64(segments, out_path)

    print(f"Nice: wrote {out_path} with {len(segments)} segments (speed={args.speed}, track={args.track})")


if __name__ == "__main__":
    main()
