# Import FastQ files

##### Description

The `Import FastQ files` operator does what it says in the name: it imports FastQ files. The output can be used for operators that deal with such data, like the `TrimGalore` and `TraCeR` operators.

##### Usage

Input projection|.
---|---
`column`        | documentId, the documentIds for the uploaded FastQ files.

Input parameters|.
---|---
`paired_end`        | whether the FastQ files correspond to paired-end or single-end sequecing.

Output relations|.
---|---
`sample`        | the sample name. This will be the full file name if the input is single-end, or the part of the filename for each pair that is shared if the input is paired-end.

##### See Also

[TraCeR_docker_operator](https://github.com/tercen/TraCeR_docker_operator)
, [trimgalore_docker_operator](https://github.com/tercen/trimgalore_docker_operator)

