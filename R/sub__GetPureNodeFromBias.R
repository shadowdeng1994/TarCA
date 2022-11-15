fun.GetPureNodeFromBias <- function(FFFilterBiasNode,TTTree){
  FFFilterBiasNode %>%
    filter(Filter) %>%
    .$NodeID %>%
    lapply(function(nnn){
      subfun.GetTips(TTTree,nnn) %>%
        tbl_df %>% rename(TipLabel=value) %>%
        mutate(Parent=paste0("Node_",nnn))
    }) %>% bind_rows %>%
    mutate(TipAnn=TRUE) %>%
    select(Parent,TipAnn,TipLabel)
}
