# Changelog for PSSort

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Added back license URI i module manifest as the bug causing PowershellGet to fail packageing the module in beta17 is resolved.

## [1.13.0] - 2022-12-15

### Added

- Added Use-SelectionSort

## [1.12.1] - 2022-11-14

### Fixed

- Fixed an issue where test-sortingalgorithms called Sort-Object with the parameter ReturnDiagnostic which is exclusive to the module provided functions.

## [1.11.0] - 2022-11-14

### Added

- Added parameter ReturnDiagnostic on sort functions. This switch will make the returned object contain information about the sorting operation performed. The sorted array will be included as an parameter of that object.

## [1.10.3] - 2022-11-13

### Changed

- Implemented a new CI/CD pipeline

## [1.10.2] - 2021-12-13

### changed

- Updated build release pipeline

## [1.10.1] - 2021-04-03

### fixed

- Updated function scripts with new psscriptinfo format

## [1.10.0] - 2021-04-01

### removed

- Removed signature from all script files due to certificate validation issue

## [1.8.0] - 2021-03-31

### added

- Added Sort-UsingBubbleSort

## [1.7.0] - 2021-03-30

### removed

- Removed incorrect license information

## [1.6.0] - 2021-03-23

### changed

- Updated module manifest private data

## [1.2.0] - 2021-03-23

### changed

- Renamed module

## [1.0.0] - 2021-03-01

### added

- First version
