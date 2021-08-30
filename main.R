library(tercen)
library(dplyr)

serialize.to.string = function(object){
  con = rawConnection(raw(0), "r+")
  saveRDS(object, con)
  str64 = base64enc::base64encode(rawConnectionValue(con))
  close(con)
  return(str64)
}
deserialize.from.string = function(str64){
  con = rawConnection(base64enc::base64decode(str64), "r+")
  object = readRDS(con)
  close(con)
  return(object)
}

ctx <- tercenCtx()

is_paired_end <- as.character(ctx$op.value('paired_end'))

documentIds <- ctx$cselect()

for (id in documentIds[[1]]) {
  
  res <- try(ctx$client$fileService$get(id),silent = TRUE)
  if (class(res) == "try-error") stop("Supplied column values are not valid documentIds.")
  
  
}

file_names <- sapply(documentIds[[1]],
                     function(x) (ctx$client$fileService$get(x))$name) %>%
  sort()

if (is_paired_end == "yes") {
  
  if((length(file_names) %% 2) != 0) stop("Non-even number of files supplied. Are you sure you've supplied paired-end files?")
  
}

output_table <- tibble()

if (is_paired_end == "no") {
  
  for (i in 1:length(file_names)) {
    
    doc <- ctx$client$fileService$get(names(file_names)[[i]])
    
    doc_bytes <- ctx$client$fileService$download(names(file_names)[[i]])
    
    doc_string <- serialize.to.string(doc_bytes)
    
    output_table <- bind_rows(output_table,
                              tibble(sample = file_names[[i]],
                                     .single_end_fastq_data = doc_string)
    )
  }
  
} else if (is_paired_end == "yes") {
  
  for (first_in_pair_index in seq(1, length(file_names), by = 2)) {
    
    docIds = file_names[first_in_pair_index:(first_in_pair_index+1)]
    
    doc_r1 <- ctx$client$fileService$get(names(docIds)[[1]])
    
    doc_r1_bytes <- ctx$client$fileService$download(names(docIds)[[1]])
    
    doc_r1_string <- serialize.to.string(doc_r1_bytes)
    
    doc_r2 <- ctx$client$fileService$get(names(docIds)[[2]])
    
    doc_r2_bytes <- ctx$client$fileService$download(names(docIds)[[2]])
    
    doc_r2_string <- serialize.to.string(doc_r2_bytes)
    
    seqlibrary_name <- substr(docIds[[1]], 1,
                              which.min(strsplit(docIds[[1]], "")[[1]] == strsplit(docIds[[2]], "")[[1]]) - 1)
    
    output_table <- bind_rows(output_table,
                              tibble(sample = seqlibrary_name,
                                     .forward_read_fastq_data = doc_r1_string,
                                     .reverse_read_fastq_data = doc_r2_string)
    )
    
  }
  
}

output_table %>%
  mutate(.ci = 1) %>%
  ctx$addNamespace() %>%
  ctx$save()
