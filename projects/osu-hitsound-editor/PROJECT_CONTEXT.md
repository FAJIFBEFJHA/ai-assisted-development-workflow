# PROJECT_CONTEXT

Last updated: 2026-10-18

## Project

`osu-hitsound-editor`

C#/.NET learning project focused on building an osu!standard hitsound editor with a DAW-like workflow.

Product repository:

```text
https://github.com/FAJIFBEFJHA/osu-hitsound-editor
```

Workflow repository:

```text
https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow
```

Product checkpoint:

```text
Branch:
    main

Commit:
    f55565adb616032065d8d197b80cfa96050db9f7

Verified remote state:
    product commit pushed to origin/main (2026-10-18); confirmed on GitHub

Local working tree:
    verify with git status when resuming on a device
```

Both repositories are public.

## Current stage

**Audio Infrastructure**

Current test status:

```text
674/674 passing; 0 failed, 0 skipped (full suite; 2026-10-18 session review)
```

Beatmap Parsing and Base Model, Hitsound Resolution, and the current Physical Sample Resolution boundary are complete.

## Current objective

On the next explicitly opened development session, extend `HitSoundPlaybackService.PlaySliderBody(...)` to play only the remaining slider-body duration and pass the elapsed slider time as `sourceOffsetMilliseconds`. Keep head-triggered prequeueing unchanged; reconstructing active sliders during an in-slider seek remains a subsequent task. The user writes production code.

Manual testing in osu!stable during the 2026-10-17/18 session confirmed that an in-slider start plays only the remaining body and preserves the original loop phase; repeating the same test in lazer is not necessary for this checkpoint.

The current production audio boundary can:

- decode WAV/MP3/OGG and normalize sources to the device mixer format
- explicitly initialize and dispose a low-latency `WasapiPlayer` with a persistent stereo float mixer
- play/pause and stop playback; `Stop()` resets a loaded timeline to the beginning
- keep the main timeline `WaveStream` open and reposition it with `Seek(...)`
- report timeline position from the seek base plus the rendered WASAPI output clock
- play transient sources with individual 0-100 volume and optional finite non-negative relative delays using `VolumeSampleProvider` and `OffsetSampleProvider`
- play finite looping sources with duration, volume, optional delay, and initial sample-phase offset using `LoopingWaveStream` and `OffsetSampleProvider.TakeSamples`
- mix multiple sources simultaneously and release their readers at the proper lifetime boundary
- release a partially initialized device if initialization throws, rethrowing the original exception
- resolve individual logical `HitSoundLayer` values to playable beatmap/custom files, handling missing/external fallback results without inventing a path
- play hit circles, slider edges, slider ticks, and finite looping slider-body layers through `HitSoundPlaybackService`
- enumerate chronological discrete `TimedHitSoundEvent` values in `(startExclusiveMilliseconds, endInclusiveMilliseconds]`
- advance/seek `TimedHitSoundPlaybackCursor` without repeating events; retain `HitCirclePlaybackCursor`
- dispatch unified events immediately via `PlayPendingTimedHitSoundEvents(...)`, or prequeue a bounded interval via `QueueTimedHitSoundEventsInRange(...)` before the mixer advances
- calculate prequeue delays from `soundEvent.Time - startMilliseconds`, with `includeStart` supporting an event exactly at the seek boundary
- prequeue `SliderSlide` and optional `SliderWhistle` through `PlaySliderBody(...)` when a slider-head event is included, using the same delay as the head and the slider's total duration; repeat/tail events do not restart the body

Prequeueing against a common interval origin is verified by mixer-frame tests and integration with timeline audio. Head-triggered slider-body playback is verified, but a prequeue interval beginning *inside* an already-running slider does not reconstruct that body. This is not an active-playback, audio-clock-driven scheduler; cursor-selected immediate dispatch remains distinct from future-event prequeueing.

## Current implementation checkpoint

### Logical hitsound resolution

The logical layer is complete and remains the source of audible hitsound intent.

Relevant behavior includes:

- effective `SampleSet`
- effective addition sample set
- effective `SampleIndex`
- effective `Volume`
- standard hitobject hitsounds
- slider edge hitsounds
- slider body `SliderSlide`
- slider body `SliderWhistle`
- slider tick timing
- slider tick hitsounds
- explicit custom filename representation

Slider edge, body, and tick responsibilities remain separate. There is no `GetAllSliderHitSounds()` API.

### Legacy slider edge inheritance

The remaining `edgeSets = 0:0` question has been resolved.

Canonical behavior:

```text
explicit slider edge NormalSet = 0
    -> unspecified
    -> inherit from the sample timing point at the edge time

explicit slider edge AdditionSet = 0
    -> inherit the resolved effective NormalSet

edge time before the first timing point
    -> use the first timing point in the beatmap
```

The slider-level trailing `HitSample.NormalSet` / `HitSample.AdditionSet` do not override an explicit edge `0:0` in this legacy path.

`GetEffectiveNormalSet(SliderEdge sliderEdge, double time)` now uses `GetSampleTimingPoint(time)` so pre-first-timing-point behavior matches the canonical legacy sample-point fallback.

### Physical sample resolution boundary

`SampleResolver` owns physical osu! sample lookup behavior.

Implemented methods include:

```text
GetStandardSampleLookup(HitSoundLayer layer)
GetSliderBodySampleLookup(HitSoundLayer layer)
GetSliderTickSampleLookup(HitSoundLayer layer)
ResolveCustomSamplePath(HitSoundLayer layer, string beatmapDirectory)
ResolveBeatmapSamplePath(string? beatmapFilename, string beatmapDirectory)
ResolveSample(HitSoundLayer layer, string beatmapDirectory)
```

Standard/slider lookup methods now return:

```text
BeatmapFilename
BeatmapUniversalFilename
FallbackFilename
```

### Physical sample lookup order

For `SampleIndex >= 1`, the deterministic beatmap lookup chain is:

```text
specific banked beatmap sample
    -> universal bankless beatmap sample
    -> external/user-skin fallback required
```

Examples of universal bankless names:

```text
hitnormal.wav
hitwhistle.wav
hitfinish.wav
hitclap.wav
sliderslide.wav
sliderwhistle.wav
slidertick.wav
```

For `SampleIndex = 0`:

```text
BeatmapFilename = null
BeatmapUniversalFilename = null
external fallback remains available
```

Therefore, `SampleIndex = 0` must not accidentally consume either banked or universal beatmap samples.

For a custom index greater than 1, an unindexed banked beatmap filename such as `normal-hitnormal.wav` is not a beatmap fallback for `normal-hitnormal2.wav`; the universal bankless candidate is used instead.

### Beatmap sample extensions

Legacy beatmap sample extension lookup remains:

```text
.wav
.mp3
.ogg
```

The first existing extension wins.

### Physical resolution result model

The existing outcomes remain sufficient:

```text
BeatmapSampleFound
ExternalFallbackRequired
CustomSampleFound
CustomSampleMissing
```

A universal bankless beatmap sample still produces `BeatmapSampleFound`; no extra outcome was introduced.

### Deferred Physical Sample Resolution work

The following are deliberately deferred rather than blockers for Audio Infrastructure:

- stable logical `SampleId`
- loading additional sample metadata before a concrete consumer requires it
- broader refactoring of duplicated standard/body/tick lookup code

Do not introduce these merely to make the current boundary look more abstract.

## Audio Infrastructure checkpoint

### Platform and dependencies

Production and test projects target:

```text
net10.0-windows
```

Current audio dependencies:

```text
NAudio 3.1.0
NAudio.Vorbis 3.0.0
```

`NAudio.SoundFile` / libsndfile is not currently required.

### Diagnostic spike findings

The temporary `tools/AudioProbe` spike was used only to answer infrastructure questions and has been removed.

Validated experimentally before removal:

- WAV, MP3, and OGG decoding
- duration and decoder seek
- `WasapiPlayer` basic play/pause/resume/stop
- seek during playback
- simultaneous hitsound mixing
- mono/stereo/sample-rate normalization
- multichannel handling
- per-layer linear volume with `VolumeSampleProvider`
- low-latency WASAPI behavior
- rendered output position as the playback timeline basis

Spike code is evidence, not production implementation. It must not be copied into `src/`; production code is reconstructed by the author through the normal learning workflow.

### Current production class

`AudioPlaybackEngine` currently owns:

```text
WasapiPlayer? outputDevice
MixingSampleProvider? mixer
Dictionary<ISampleProvider, WaveStream> activeReaders
WaveStream? timelineReader
ISampleProvider? timelineProvider
object activeReadersLock
double timelineBaseMilliseconds
```

and contains:

```text
InitializeOutput() -> void
GetInitializedOutputDevice() -> WasapiPlayer
Play() -> void
Pause() -> void
Stop() -> void
Seek(double timeMilliseconds) -> void
GetTimelinePositionMilliseconds() -> double
LoadTimelineAudio(string filePath) -> void
AddAudioSource(string filePath, int volume = 100, double delayMilliseconds = 0) -> void
AddLoopingAudioSource(string filePath, double durationMilliseconds, int volume = 100, double delayMilliseconds = 0, double sourceOffsetMilliseconds = 0) -> void
OnMixerInputEnded(object? sender, SampleProviderEventArgs e) -> void
OpenAudioFile(string filePath) -> WaveStream
NormalizeForMixer(WaveStream reader, int targetSampleRate) -> ISampleProvider
Dispose() -> void
```

`InitializeOutput()`:

```text
if already initialized
    -> InvalidOperationException

WasapiPlayerBuilder
    -> WithLowLatency()
    -> Build()
    -> WasapiPlayer

target sample rate
    -> outputDevice.DeviceMixFormat.SampleRate

mixer format
    -> IEEE float
    -> target device sample rate
    -> 2 channels

mixer
    -> persistent MixingSampleProvider
    -> ReadFully = true

device.Init(currentMixer)
    -> only on success, assign outputDevice and mixer fields
    -> on failure, unsubscribe mixer event, dispose device, rethrow
```

Initialization is explicit rather than constructor-driven. Constructing `AudioPlaybackEngine` alone does not open a physical audio device, so decoding/normalization tests remain hardware-independent. The successful device path is integration-tested; forcing an internal initialization failure is not covered by the permanent suite.

`GetInitializedOutputDevice()` centralizes the shared precondition used by `Play()`, `Pause()`, `Stop()`, `Seek(...)`, and `GetTimelinePositionMilliseconds()`:

```text
outputDevice == null
    -> InvalidOperationException

otherwise
    -> return outputDevice
```

`Dispose()` releases the owned `WasapiPlayer` and clears the persistent output/mixer references.

`OpenAudioFile(...)`:

```text
missing file
    -> FileNotFoundException

.wav / .mp3
    -> AudioFileReader

.ogg
    -> VorbisWaveReader

other extension
    -> NotSupportedException
```

`NormalizeForMixer(...)`:

```text
WaveStream
    -> ToSampleProvider()

mono
    -> MonoToStereoSampleProvider

more than 2 channels
    -> MultiplexingSampleProvider
    -> input 0 -> output 0
    -> input 1 -> output 1

sample rate differs from target
    -> WdlResamplingSampleProvider

return current ISampleProvider
```

`AddAudioSource(...)`:

```text
require volume in 0..100 and finite non-negative delay
    -> ArgumentOutOfRangeException otherwise

require initialized mixer
    -> InvalidOperationException otherwise

calculate delayFrames = delayMilliseconds * sampleRate / 1000
reject delay beyond supported interleaved sample range
calculate delaySamples = truncated whole frames * channel count

OpenAudioFile(filePath)
    -> WaveStream

NormalizeForMixer(reader, mixer.WaveFormat.SampleRate)
    -> normalizedProvider

VolumeSampleProvider(normalizedProvider)
    -> volumeProvider.Volume = volume / 100f

mixerInput = volumeProvider
if delaySamples > 0
    -> OffsetSampleProvider(volumeProvider)
    -> DelayBySamples = delaySamples
    -> mixerInput = delayed provider

register mixerInput -> reader in activeReaders
mixer.AddMixerInput(mixerInput)
on mixer-add failure, unregister mixerInput and dispose its reader
```

`LoopingWaveStream` provides the finite-looping read boundary:

```text
requires a seekable WaveStream containing at least one complete audio frame
resets source position to the beginning on construction
reads complete frames; when the source ends, rewinds and continues
supports Span<byte> and byte[] reads
does not own or dispose the underlying source reader
```

`AddLoopingAudioSource(...)` provides the playback/lifetime boundary:

```text
validate finite positive duration, volume in 0..100, finite non-negative delay and source offset
validate that duration and delay fit whole mixer frames and interleaved sample counts
open a WaveStream; wrap in LoopingWaveStream without transferring reader ownership
convert source offset to original-source frames; reject non-finite or >= 2^53 frame offsets
compute phase frame modulo original-source frame count and seek to the frame-aligned byte position
normalize to the mix sample rate/stereo; apply VolumeSampleProvider
wrap in OffsetSampleProvider with TakeSamples and DelayBySamples
register the inserted provider and its original WaveStream in activeReaders
dispose reader if provider construction or mixer registration fails
release reader on mixer input end or AudioPlaybackEngine.Dispose()
```

Source-reader ownership is explicit:

```text
before registration
    -> AddAudioSource or AddLoopingAudioSource owns the WaveStream

after registration
    -> AudioPlaybackEngine owns the WaveStream

MixerInputEnded
    -> remove provider -> reader ownership entry
    -> dispose reader

AudioPlaybackEngine.Dispose()
    -> stop/dispose output
    -> remove mixer inputs
    -> claim remaining active readers
    -> dispose them outside the ownership lock
```

All access that mutates `activeReaders` is protected by `activeReadersLock`. Resource disposal occurs outside that lock.

`LoadTimelineAudio(...)` introduces a separate persistent lifetime for the beatmap's main timeline audio:

```text
require initialized mixer
    -> InvalidOperationException otherwise

require no timeline source already loaded
    -> InvalidOperationException otherwise

OpenAudioFile(filePath)
    -> timelineReader

NormalizeForMixer(
    timelineReader,
    mixer.WaveFormat.SampleRate)
    -> timelineProvider

mixer.AddMixerInput(timelineProvider)
```

Unlike temporary sources managed by `activeReaders`, the timeline `WaveStream` remains owned by `AudioPlaybackEngine` after its mixer input ends. `OnMixerInputEnded(...)` clears `timelineProvider` but deliberately keeps `timelineReader` alive so it can be repositioned and normalized again for a future seek. `Dispose()` releases the persistent timeline reader.

`Seek(...)` validates a finite position within the timeline duration, stops/resets the output clock, clears mixer inputs and transient-reader ownership, repositions the persistent timeline reader, creates a fresh normalized provider, updates `timelineBaseMilliseconds`, and resumes only if playback had been active. Reusing a consumed resampler after seeking would retain stale state.

`GetTimelinePositionMilliseconds()` converts `WasapiPlayer.GetPosition()` bytes with `OutputWaveFormat.AverageBytesPerSecond` and adds `timelineBaseMilliseconds`. Decoder `CurrentTime` is not the editor clock. `Stop()` now stops the device and invokes `Seek(0)` when a timeline source is loaded.

### Discrete event cursor, relative delays, and prequeueing

`Beatmap.GetTimedHitSoundEventsInRange(...)` combines hit circles, slider edges, and slider ticks. Each `TimedHitSoundEvent` carries an absolute `Time`, `HitObject`, `HitSoundEventType`, and an optional slider `EdgeIndex`. Results are chronological with an exclusive lower bound and inclusive upper bound.

`TimedHitSoundPlaybackCursor.AdvanceTo(...)` and `SeekTo(...)` track unified discrete-event progress, including time-zero events and repeated/seeked intervals. `HitCirclePlaybackCursor` remains available. `PlayPendingTimedHitSoundEvents(...)` dispatches cursor-selected events immediately; it does not schedule them by their timestamps.

`HitSoundPlaybackService` propagates optional `delayMilliseconds` through layer, circle, slider-edge, slider-tick, and unified-event playback. `AudioPlaybackEngine.AddAudioSource(...)` uses `OffsetSampleProvider` to produce silence before the source begins. Registration and reader cleanup use the provider actually inserted into the mixer.

`QueueTimedHitSoundEventsInRange(...)` selects events, computes relative delays from the interval's start, and adds those sources before audio playback advances. `includeStart = true` includes a seek-boundary event with zero delay; the default preserves exclusive-start behavior for nonzero starts. Start time zero includes zero-time events by default.

Prequeueing works with a common pre-playback origin, not with a clock-driven lookahead scheduler during playback. `HitSoundPlaybackService.PlaySliderBody(...)` resolves `SliderSlide` and optional `SliderWhistle` logical layers, then passes available local files to `AudioPlaybackEngine.AddLoopingAudioSource(...)` for the full duration returned by `Beatmap.GetSliderDuration(slider)`. Missing custom samples or external fallback requirements are returned without attempting playback.

`QueueTimedHitSoundEventsInRange(...)` calls `PlaySliderBody(...)` only for an included slider-head (`SliderEdge` with `EdgeIndex = 0`) and passes the same relative delay as the head. The returned body resolution results are appended to that event's results. Repeats/tails do not restart the body. Starting or seeking *inside* a slider is still unhandled: the head is outside the selected interval, so this path does not queue its remaining continuous sound.

### Verification boundary

Automated tests remain hardware-independent.

Permanent tests cover the uninitialized-output contracts, volume, delayed sample frames, ownership/cleanup of delayed mixer inputs, unified cursor behavior, event prequeueing (including `includeStart`), overlapping sounds, alignment with timeline audio, finite looping with duration/delay limits and reader cleanup, and slider-body integration (duration, whistle, delay, missing-sample outcomes, invalid inputs, and head/body mixer-frame alignment).

Focused WASAPI integration checks verified pause/resume with queued hitsounds, pause-seek-requeue-play, and stop/requeue from the beginning, in addition to earlier timeline/device checks. Temporary hardware-dependent tests were removed after verification. The internal `device.Init(...)` failure path was reviewed structurally, not forcibly triggered.

## Test progression

Meaningful full-suite checkpoints:

```text
210/210  2026-10-10; core audio infrastructure and mixer volume
500/500  2026-10-11; discrete event dispatch and interval selection
605/605  2026-10-12; unified cursor, relative delays, prequeueing, seek-boundary handling
646/646  2026-10-13; finite looping WaveStream and duration-limited mixer sources
669/669  2026-10-14; slider-body playback and integration into the timed-event prequeue path
674/674  2026-10-18; phase-aligned looping source offsets and 5 new test cases
```

The 2026-10-18 session review reported 674 passed, 0 failed, 0 skipped (`dotnet test` exit code 0); `git diff --check` was clean. The published product commit `f55565adb616032065d8d197b80cfa96050db9f7` contains the new `AddLoopingAudioSource(...)` offset parameter, phase-aligned frame positioning, 5 new test cases, and updates to `docs/ROADMAP.md` and `docs/architecture.md`. The previous 669/669 checkpoint from 2026-10-14 remains historical. Actual source and tests remain authoritative if later results differ.

## Workflow tooling

The workflow is maintained in the separate `ai-assisted-development-workflow` repository under `projects/osu-hitsound-editor/`. The two-repository migration is **COMPLETE**; product code and documentation remain in the product repository, and maintainer/AI procedures and checkpoints remain in the workflow repository.

The workflow repository owns the verified scripts `New-SessionReview.ps1` (review both repositories and run the product test suite when a meaningful product checkpoint requires it) and `Sync-ProjectContext.ps1` (synchronize the optional seven-file continuity mirror with SHA256 verification). Both scripts require `-ProductRepository` and are documented in `WORKFLOW.md`. No product-repository workflow fallback exists.

Historical migration commits, migration-era test results and implementation details of these scripts remain in Git history and the operational documentation; they are not active product checkpoints. The product repository also contains its `.editorconfig` for source naming/style conventions.

## Important / technical debt

Do not mix these into the next audio step unless they become blockers:

- define stable logical `SampleId` only when a concrete identity consumer requires it
- load only audio/sample metadata that a concrete editor/playback requirement needs
- revisit `GetHitSoundLayers(SliderEdge, HitSample, double time)` signature only during a deliberate API review
- use `CultureInfo.InvariantCulture` consistently when parser robustness work resumes
- improve malformed/empty parser-field handling later
- keep the lazer-specific spinner traversal sound deferred from the canonical legacy model
- evaluate runtime audio-device loss/recovery only when there is a concrete consumer; partial initialization cleanup is implemented but the forced-failure path remains untested
- active-playback, clock-driven scheduling and seek/queue controller orchestration remain deferred; prequeueing assumes the mixer has not consumed the interval
- `Stop()` only clears queued transient hitsounds through `Seek(0)` when timeline audio is loaded; hitsound-only stop behavior is not addressed yet
- finite `SliderSlide` / `SliderWhistle` playback is implemented at the slider head, but the remaining body must be reconstructed when a seek/start occurs after that head and before the slider tail
- do not introduce global optimization before deterministic export/reload equivalence exists

## Exact next workflow task

The workflow-documentation audit is complete and published. No workflow-audit task is pending. Follow `WORKFLOW.md` for repository publication, cross-repository checkpoint updates, and optional mirror synchronization.

## Planned architecture milestone (after Audio Infrastructure)

Product documentation commit `35015f80049b4aca7334921b57e4d3f8b2abb5e7` records decision D027 in `docs/DECISIONS.md` and the architecture-review/refactoring milestone in `docs/ROADMAP.md`, scheduled **after Audio Infrastructure and before WPF editor implementation**. The intended direction is a modular monolith with clear domain, application-coordination, and infrastructure responsibilities, plus MVVM for WPF; adopt abstractions or multiple projects only when justified by verified consumers and costs. The architecture review and refactoring have **not** started.

That historical commit changed documentation only. The subsequent 2026-10-18 product commit adds a tested audio feature. Current full-suite verification is **674/674 passing on 2026-10-18**.

## Exact next product task

On the next explicit session opening, inspect the current local body of `HitSoundPlaybackService.PlaySliderBody(...)`, then have the user extend it with optional elapsed-slider time to calculate remaining duration (`GetSliderDuration(slider) - elapsedMilliseconds`) and pass `sourceOffsetMilliseconds: elapsedMilliseconds` to the now-verified engine method. Preserve head-start behavior, sample resolution, existing reader ownership, and slider-edge/tick independence; verify duration, phase, and invalid/boundary inputs with hardware-independent tests before addressing detection of sliders active at an in-slider seek. The user authors all `src/` code.

Do not begin an active-playback scheduler, UI work, global optimizer, or a speculative playback-controller abstraction in this step.

## Source-of-truth order

When sources disagree, use this order:

1. Tests and actual source code
2. Official osu! documentation / official open-source implementation for format behavior
3. Product repository `docs/DECISIONS.md`
4. Workflow repository `projects/osu-hitsound-editor/PROJECT_CONTEXT.md`
5. Product repository `docs/ROADMAP.md`
6. Product repository `docs/architecture.md`
7. Chat history or AI suggestions
