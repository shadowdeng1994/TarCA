fun.GetCombinationFromList <- function(ListIn){
  tmp.out <- ListIn[[1]] %>% tbl_df %>% mutate(AAA=1)
  for(i in 2:length(ListIn)){ tmp.out <- tmp.out %>% left_join(ListIn[[i]] %>% tbl_df %>% mutate(AAA=1),by="AAA")}
  tmp.out <- tmp.out %>% select(-AAA)
  if(length(names(ListIn))>0){
    tmp.names <- names(ListIn)
  }else{
    tmp.names <- paste0("V",1:length(ListIn))
  }
  colnames(tmp.out) <- tmp.names
  return(tmp.out)
}
