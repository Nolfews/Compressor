# imageCompressor

`imageCompressor` is a Haskell command-line tool that reduces the number of
colors in an image by grouping similar pixel colors with the k-means clustering
algorithm. It is designed for pixel data exported as text rather than for
reading or writing image formats directly.

## Features

- Cluster pixel colors into a configurable number of groups.
- Stop clustering when the requested convergence limit is reached.
- Validate pixel coordinates and RGB values while parsing the input file.
- Print each cluster with its calculated centroid and the pixels assigned to it.

## Requirements

- GHC and [Stack](https://docs.haskellstack.org/en/stable/README/)
- A Unix-like shell, or an environment that provides the commands used by the
	Makefile

## Build

Build the project with Stack:

```sh
stack build
```

Or use the Makefile, which also copies the built executable to the project
root:

```sh
make
```

The executable is named `imageCompressor`.

## Usage

```text
imageCompressor -n <number-of-colors> -l <convergence-limit> -f <input-file>
```

Options:

| Option | Description |
| --- | --- |
| `-n N` | Number of color clusters to produce. |
| `-l L` | Convergence limit used by k-means. |
| `-f F` | Path to the input file containing pixel data. |

For example:

```sh
./imageCompressor -n 4 -l 0.01 -f pixels.txt
```

When running directly through Stack, use:

```sh
stack run -- -n 4 -l 0.01 -f pixels.txt
```

## Input format

The input file must contain one pixel per line. A pixel is written as a point
followed by an RGB color:

```text
(x,y) (r,g,b)
```

For example:

```text
(0,0) (33,18,109)
(0,1) (33,18,109)
(1,0) (35,18,109)
```

Coordinates are integer pairs. Each RGB component must be an integer from 0 to
255. Blank lines are ignored, but malformed non-empty lines cause the program
to fail.

## Output format

The program prints one block for each non-empty cluster. The first color in a
block is the cluster centroid; the following lines list the original pixels and
their colors:

```text
--
(34,18,109)
-
(0,0) (33,18,109)
(0,1) (33,18,109)
```

## Tests

Run the test suite with:

```sh
stack test
```

To remove build artifacts and the copied executable:

```sh
make fclean
```
