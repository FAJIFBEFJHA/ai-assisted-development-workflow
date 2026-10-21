# PROJECT_CONTEXT

Last updated: 2026-10-21

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
    1c75405d3a131f367e4c9c8be692c6c012d1c7e7

Verified remote state:
    product commit published and verified on main (2026-10-21)

Local working tree:
    clean after publication; verify with git status when resuming on a device
```

Both repositories are public.

## Current stage

**Audio Infrastructure**

Current test status:

```text
741/741 passing; 0 failed, 0 skipped (full suite; 2026-10-21 00:26:29 via New-SessionReview.ps1)
```

Beatmap Parsing and Base Model, Hitsound Resolution, and the current Physical Sample Resolution boundary are complete.

## Current objective

Begin the next session by defining and documenting a collaboration procedure with Codex to streamline session closure. Evaluate and agree on the provisional division of responsibilities before changing `WORKFLOW.md` or `AI_WORKFLOW.md`, and define session size by meaningful roadmap milestones rather than arbitrary duration. Only then resume production work progressively on `FrameScheduledSampleProvider`, starting with its structure, constructor, and `WaveFormat` property. The user writes production code.

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
- explicitly play only the remaining body of a slider using `PlaySliderBody(..., elapsedMilliseconds: ...)`, preserving its original sample-loop phase
- enumerate chronological discrete `TimedHitSoundEvent` values in `(startExclusiveMilliseconds, endInclusiveMilliseconds]`
- advance/seek `TimedHitSoundPlaybackCursor` without repeating events; retain `HitCirclePlaybackCursor`
- dispatch unified events immediately via `PlayPendingTimedHitSoundEvents(...)`, or prequeue a bounded interval via `QueueTimedHitSoundEventsInRange(...)` before the mixer advances
- calculate prequeue delays from `soundEvent.Time - startMilliseconds`, with `includeStart` supporting an event exactly at the seek boundary
- prequeue `SliderSlide` and optional `SliderWhistle` through `PlaySliderBody(...)` when a slider-head event is included, using the same delay as the head and the slider's total duration; repeat/tail events do not restart the body
- identify strictly active sliders with `Beatmap.GetActiveSlidersAt(...)` and reconstruct their continuous bodies with `HitSoundPlaybackService.QueueActiveSliderBodiesAt(...)`, preserving original phase and remaining duration through elapsed time
- prepare discrete events and already-active continuous bodies together with `HitSoundPlaybackService.QueuePlaybackInterval(...)`, keeping their results separate and avoiding duplicate head-triggered bodies

Prequeueing against a common interval origin is verified by mixer-frame tests and integration with timeline audio. Both head-triggered playback and reconstruction of bodies already active at the interval start are implemented and verified. This is not an active-playback, audio-clock-driven scheduler; cursor-selected immediate dispatch remains distinct from future-event prequeueing.

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

Prequeueing works with a common pre-playback origin, not with a clock-driven lookahead scheduler during playback. `HitSoundPlaybackService.PlaySliderBody(...)` resolves `SliderSlide` and optional `SliderWhistle` logical layers, validates optional `elapsedMilliseconds` within `[0, slider duration)`, and passes available local files to `AudioPlaybackEngine.AddLoopingAudioSource(...)` with `remainingDurationMilliseconds = beatmap.GetSliderDuration(slider) - elapsedMilliseconds` and `sourceOffsetMilliseconds: elapsedMilliseconds`. The default offset of zero preserves full-duration slider-head playback. Missing custom samples or external fallback requirements are returned without attempting playback.

`QueueTimedHitSoundEventsInRange(...)` calls `PlaySliderBody(...)` only for an included slider-head (`SliderEdge` with `EdgeIndex = 0`) and passes the same relative delay as the head. The returned body resolution results are appended to that event's results. Repeats/tails do not restart the body. This path alone does not discover bodies whose heads precede the interval; the completed interval preparation below handles them.

`Beatmap.GetActiveSlidersAt(...)` identifies sliders strictly active at an instant, excluding their head and tail boundaries. `HitSoundPlaybackService.QueueActiveSliderBodiesAt(...)` reconstructs those continuous bodies using elapsed time to preserve their original phase and remaining duration. `HitSoundPlaybackService.QueuePlaybackInterval(...)` prepares both discrete events and already-active continuous bodies, keeps their results separate, and avoids duplicate bodies at slider heads. Active-slider reconstruction is complete, not a pending task.

### Scheduler investigation and remaining boundary

Two temporary diagnostic experiments passed: generated-frame accounting (7/7 checks), and scheduling at buffer boundaries with controlled concurrency (9/9 checks). All 16 diagnostic checks passed; the diagnostic files were removed before the checkpoint and are not part of the permanent suite.

The experiments established that the WASAPI-reported position differs from the position through which the mixer has generated audio. A wrapper provider can count delivered frames, and segmented reads can start events at specific frames. Late events require explicit detection. The prototype does not yet demonstrate general concurrency safety.

There is no production scheduler implementation. `FrameScheduledSampleProvider` remains pending. Reduced-speed playback and `SamplesMatchPlaybackRate` are future requirements, not implemented features.

### Verification boundary

Automated tests remain hardware-independent.

Permanent tests cover the uninitialized-output contracts, volume, delayed sample frames, ownership/cleanup of delayed mixer inputs, unified cursor behavior, event prequeueing (including `includeStart`), overlapping sounds, alignment with timeline audio, finite looping with duration/delay limits and reader cleanup, and slider-body integration (duration, whistle, delay, missing-sample outcomes, invalid inputs, head/body mixer-frame alignment, elapsed-time validation, preserved phase, and remaining-duration cutoff). The latest 60 permanent cases cover active-slider detection, continuous-body reconstruction, and combined interval preparation with separate results and no duplicate head-triggered bodies.

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
681/681  2026-10-18; elapsed slider-body playback and 7 new test cases
741/741  2026-10-21; active-slider reconstruction and interval preparation; 60 new test cases
```

The 2026-10-18 session review reported 674 passed, 0 failed, 0 skipped (`dotnet test` exit code 0); `git diff --check` was clean. The published product commit `f55565adb616032065d8d197b80cfa96050db9f7` contains the new `AddLoopingAudioSource(...)` offset parameter, phase-aligned frame positioning, 5 new test cases, and updates to `docs/ROADMAP.md` and `docs/architecture.md`. The previous 669/669 checkpoint from 2026-10-14 remains historical. Actual source and tests remain authoritative if later results differ.

The later 2026-10-18 session review reported 681 passed, 0 failed, 0 skipped (`dotnet test` exit code 0); `git diff --check` was clean. Product commit `d9466dc1ba4eaf9d51940dcd543db16832137866`, verified on GitHub, extends `HitSoundPlaybackService.PlaySliderBody(...)` with elapsed-time validation, remaining-duration playback and phase preservation, adds 7 test cases, and updates `docs/ROADMAP.md` and `docs/architecture.md`.

The latest full verification, performed through `New-SessionReview.ps1` on 2026-10-21 at 00:26:29, reported 741 passed, 0 failed, 0 skipped. Published and verified product commit `1c75405d3a131f367e4c9c8be692c6c012d1c7e7` on `main` includes the three completed methods `Beatmap.GetActiveSlidersAt(...)`, `HitSoundPlaybackService.QueueActiveSliderBodiesAt(...)`, and `HitSoundPlaybackService.QueuePlaybackInterval(...)`. The suite grew from 681 to 741 permanent tests; the 16 temporary scheduler diagnostics are separate. The product working tree was clean after publication.

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
- `FrameScheduledSampleProvider` remains pending; diagnostic frame accounting and segmented reads do not constitute a production scheduler or establish general concurrency safety
- reduced-speed playback and `SamplesMatchPlaybackRate` remain future requirements
- do not introduce global optimization before deterministic export/reload equivalence exists

## Exact next workflow task

The workflow-documentation audit is complete and published. No workflow-audit task is pending. Follow `WORKFLOW.md` for repository publication, cross-repository checkpoint updates, and optional mirror synchronization.

The first task of the next session is to define and document a collaboration procedure with Codex to streamline closures, before resuming production code. In the completed experiment, Codex directly edited product `ROADMAP.md` and `architecture.md` using GPT-6.1 Sol with Medium reasoning. Reported time was approximately 3 minutes, with approximately 2% of the 5-hour limit consumed. ChatGPT subsequently reviewed the diff and its correspondence with the code; the user retained authorization of commits and publication.

This division of responsibilities is provisional and must be evaluated and agreed before modifying `WORKFLOW.md` or `AI_WORKFLOW.md`. Also agree on session size based on meaningful roadmap milestones rather than arbitrary duration. The completed documentation audit does not resolve these new workflow questions.

## Planned architecture milestone (after Audio Infrastructure)

Product documentation commit `35015f80049b4aca7334921b57e4d3f8b2abb5e7` records decision D027 in `docs/DECISIONS.md` and the architecture-review/refactoring milestone in `docs/ROADMAP.md`, scheduled **after Audio Infrastructure and before WPF editor implementation**. The intended direction is a modular monolith with clear domain, application-coordination, and infrastructure responsibilities, plus MVVM for WPF; adopt abstractions or multiple projects only when justified by verified consumers and costs. The architecture review and refactoring have **not** started.

That historical commit changed documentation only. Subsequent product commits add verified audio features. Current full-suite verification is **741/741 passing on 2026-10-21**.

## Exact next product task

Only after the workflow task above has been evaluated and agreed, resume `FrameScheduledSampleProvider` progressively, beginning with its structure, constructor, and `WaveFormat` property. Use the temporary scheduler findings as evidence while keeping late-event detection and general concurrency safety unresolved until implemented and verified. The user authors all `src/` code.

Active-slider reconstruction is already complete. The scheduler itself remains unimplemented; reduced-speed playback and `SamplesMatchPlaybackRate` remain future requirements. Do not expand this initial step into UI work, a global optimizer, or a speculative playback-controller abstraction.

## Source-of-truth order

When sources disagree, use this order:

1. Tests and actual source code
2. Official osu! documentation / official open-source implementation for format behavior
3. Product repository `docs/DECISIONS.md`
4. Workflow repository `projects/osu-hitsound-editor/PROJECT_CONTEXT.md`
5. Product repository `docs/ROADMAP.md`
6. Product repository `docs/architecture.md`
7. Chat history or AI suggestions
