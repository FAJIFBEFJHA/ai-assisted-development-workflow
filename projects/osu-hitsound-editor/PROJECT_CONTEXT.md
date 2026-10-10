# PROJECT_CONTEXT

Last updated: 2026-10-10

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
    2530b2d78f457f6ec88c1eab0d185ad7ef9fb9b7

Verified repository state:
    clean
    up to date with origin/main
```

Both repositories are public.

## Current stage

**Audio Infrastructure**

Current test status:

```text
210/210 passing (full suite; 2026-10-10 session review)
```

Beatmap Parsing and Base Model, Hitsound Resolution, and the current Physical Sample Resolution boundary are complete.

## Current objective

Continue Audio Infrastructure by connecting a single logical hitsound layer to physical sample resolution and audio playback, without introducing a global scheduler or UI yet.

The current production audio boundary can:

- decode WAV/MP3/OGG and normalize sources to the device mixer format
- explicitly initialize and dispose a low-latency `WasapiPlayer` with a persistent stereo float mixer
- play/pause and stop playback; `Stop()` resets a loaded timeline to the beginning
- keep the main timeline `WaveStream` open and reposition it with `Seek(...)`
- report timeline position from the seek base plus the rendered WASAPI output clock
- play transient sources with individual 0-100 volume through `VolumeSampleProvider`
- mix multiple sources simultaneously and release their readers at the proper lifetime boundary
- release a partially initialized device if initialization throws, rethrowing the original exception

Next, connect `HitSoundLayer` to `SampleResolver.ResolveSample(...)` and to `AudioPlaybackEngine.AddAudioSource(...)` for one physically resolved file, preserving volume and distinguishing missing/external fallback outcomes. Do not assume those outcomes contain playable paths.

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
AddAudioSource(string filePath, int volume = 100) -> void
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
require volume in 0..100
    -> ArgumentOutOfRangeException otherwise

require initialized mixer
    -> InvalidOperationException otherwise

OpenAudioFile(filePath)
    -> WaveStream

NormalizeForMixer(reader, mixer.WaveFormat.SampleRate)
    -> normalizedProvider

VolumeSampleProvider(normalizedProvider)
    -> volumeProvider.Volume = volume / 100f

register:
    volumeProvider -> reader

mixer.AddMixerInput(volumeProvider)
```

Source-reader ownership is explicit:

```text
before registration
    -> AddAudioSource owns the WaveStream

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

### Verification boundary

Automated tests remain hardware-independent.

Current permanent automated coverage includes the uninitialized-output contract for `Play()`, `Pause()`, `Stop()`, `Seek(...)`, `GetTimelinePositionMilliseconds()`, `AddAudioSource(...)`, and `LoadTimelineAudio(...)`. Volume range, sample amplitude scaling, and simultaneous mixing of two volume-adjusted sources are covered without a physical output device.

Focused real-device integration tests also verified transient-reader release, persistent timeline-reader lifetime, seeks during playback and from paused/stopped states, rendered-clock advancement across seek, stop/restart positioning, and successful output initialization. These temporary device-dependent tests were removed after verification; the internal `device.Init(...)` failure path was reviewed structurally, not forcibly triggered.

## Test progression

Recent checkpoints:

```text
182/182  legacy slider sample-source semantics and fallback coverage
185/185  edgeSets = 0:0 / pre-first-timing-point inheritance coverage
190/190  universal bankless beatmap sample fallback coverage
193/193  audio file opening/error coverage
197/197  audio format normalization coverage
198/198  Play() uninitialized-output contract
199/199  Pause() uninitialized-output contract
200/200  Stop() uninitialized-output contract
201/201  AddAudioSource() uninitialized-output contract
202/202  LoadTimelineAudio() uninitialized-output contract
203/203  Seek() uninitialized-output contract
204/204  GetTimelinePositionMilliseconds() uninitialized-output contract
206/206  invalid source volume boundaries
209/209  volume amplitude scaling at 0, 50 and 100
210/210  two concurrent volume-adjusted sources
```

The session review on 2026-10-10 verified the entire permanent suite: 210 passed, 0 failed, 0 skipped. Treat actual source and tests as the implementation truth if this list becomes stale.

## Workflow tooling

A repository `.editorconfig` remains present in the product repository for naming/style alignment.

The project-specific maintainer/AI workflow now has its candidate home at:

```text
ai-assisted-development-workflow/
    projects/osu-hitsound-editor/
```

Current project-specific workflow files:

```text
PROJECT_PROFILE.md
PROJECT_CONTEXT.md
WORKFLOW.md
AI_WORKFLOW.md
scripts/New-SessionReview.ps1
scripts/Sync-ProjectContext.ps1
```

`New-SessionReview.ps1` has been adapted and locally verified from the workflow repository. It now:

```text
receives the product repository through -ProductRepository
discovers the workflow repository from $PSScriptRoot
runs the product test suite
reviews both repositories
writes one report outside both repositories
replaces local repository paths with portable placeholders
preserves UTF-8 text correctly under Windows PowerShell 5.1
```

Migration-era verification (historical):

```text
Product HEAD:
    398aa417fb4d26fdfe76232f518a2383fff4f34b

Product tests:
    202/202 passing

Product repository:
    clean
    up to date with origin/main

Workflow repository:
    initial workflow commit cb0b666a97082f9cee496f3721c167bdd990ca12
    pushed and independently retrievable
```

The workflow-repository `New-SessionReview.ps1` successfully reviewed the product after the old product-side workflow files were removed from the working tree. The product baseline remained 202/202 passing.

`Sync-ProjectContext.ps1` has also been adapted and locally verified. It now assembles the continuity mirror from both repositories:

```text
WORKFLOW REPOSITORY
    PROJECT_PROFILE.md
    PROJECT_CONTEXT.md
    WORKFLOW.md
    AI_WORKFLOW.md

PRODUCT REPOSITORY
    docs/ROADMAP.md
    docs/DECISIONS.md
    docs/architecture.md
```

A temporary mirror test copied all seven files successfully, and every source/destination SHA256 comparison matched.

## Workflow migration status

The workflow split is **COMPLETE**.

Verified migration checkpoint:

```text
workflow repository initial commit:
    cb0b666a97082f9cee496f3721c167bdd990ca12
    pushed and independently retrievable

product migration commit:
    398aa417fb4d26fdfe76232f518a2383fff4f34b
    pushed to main

product repository:
    old workflow/context documents removed
    old workflow scripts removed
    clean and up to date with origin/main

session review:
    runs from the separate workflow repository
    reviews both repositories
    product tests 202/202 passing

continuity mirror:
    seven-file synchronization from both repositories verified
    SHA256 verification passed
```

The workflow repository is now authoritative for maintainer/AI workflow and continuity files. The product repository remains authoritative for source code, tests, product architecture, decisions, roadmap, and public/contributor documentation.

## Important / technical debt

Do not mix these into the next audio step unless they become blockers:

- define stable logical `SampleId` only when a concrete identity consumer requires it
- load only audio/sample metadata that a concrete editor/playback requirement needs
- revisit `GetHitSoundLayers(SliderEdge, HitSample, double time)` signature only during a deliberate API review
- use `CultureInfo.InvariantCulture` consistently when parser robustness work resumes
- improve malformed/empty parser-field handling later
- keep the lazer-specific spinner traversal sound deferred from the canonical legacy model
- evaluate runtime audio-device loss/recovery only when there is a concrete consumer; partial initialization cleanup is implemented but the forced-failure path remains untested
- do not introduce global optimization before deterministic export/reload equivalence exists

## Exact next workflow task

Resume the established two-repository workflow with proportional verification. Keep `PROJECT_CONTEXT.md` tied to the exact pushed product commit and synchronize the optional mirror only after authoritative repository changes are pushed. No unfinished workflow migration work remains.

## Exact next product task

Connect one `HitSoundLayer` to physical sample resolution and playback, preserving the existing responsibility boundaries:

```text
logical HitSoundLayer
    -> SampleResolver.ResolveSample(layer, beatmapDirectory)
    -> SampleResolutionResult

when ResolvedPath represents an existing beatmap/custom sample
    -> AudioPlaybackEngine.AddAudioSource(ResolvedPath, layer.Volume)

missing custom sample or external fallback required
    -> handle the outcome explicitly; do not invent a playable path
```

Choose the smallest method responsibility and deterministic tests before implementing. Do not introduce event scheduling, editor UI, global coordination, or external-fallback asset management as part of this first single-layer connection.

## Source-of-truth order

When sources disagree, use this order:

1. Tests and actual source code
2. Official osu! documentation / official open-source implementation for format behavior
3. Product repository `docs/DECISIONS.md`
4. Workflow repository `projects/osu-hitsound-editor/PROJECT_CONTEXT.md`
5. Product repository `docs/ROADMAP.md`
6. Product repository `docs/architecture.md`
7. Chat history or AI suggestions
