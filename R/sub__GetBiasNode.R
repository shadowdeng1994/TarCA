fun.GetBiasNode <- function(TTTree,AAAnn){
  ## Background
  tmp.Background <- subfun.GetBackground(AAAnn)

  ## Get subtree
  tmp.Subtree <- castor::get_subtrees_at_nodes(TTTree,1:TTTree$Nnode)$subtrees

  ## Chisq-test
  tmp.chisq <-
    1:length(tmp.Subtree) %>%
    lapply(function(nnn){ subfun.DetectBiasWithChisq(nnn,tmp.Subtree,AAAnn,tmp.Background) }) %>%
    bind_rows

  tmp.out <-
    tmp.chisq %>%
    ## fdr < 0.05
    group_by %>% mutate(padj=stats::p.adjust(pval,"fdr")) %>% filter(padj<0.05) %>%
    ## Enrich in Up-pop
    filter(Bias>Background) %>%
    mutate(node=NodeID+subfun.NTip(TTTree))

  return(tmp.out)
}

# ================================
subfun.GetBackground <- function(AAAnn){
  AAAnn %>%
  group_by(TipAnn) %>% summarise(Count=n()) %>%
  group_by %>% mutate(Freq=Count/sum(Count)) %>%
  group_by %>% right_join(data.frame(TipAnn=c(TRUE,FALSE)),by="TipAnn") %>%
  mutate(Count=replace_na(Count,0)) %>% arrange(TipAnn)
}

# ================================
subfun.DetectBiasWithChisq <- function(NNN,SSSubtree,AAAnn,BBBackground){
  SSSubtree[[NNN]]$tip.label %>%
  tbl_df %>% rename(TipLabel=value) %>%
  left_join(AAAnn,by="TipLabel") %>%
  group_by(TipAnn) %>% summarise(Count=n()) %>%
  group_by %>% right_join(data.frame(TipAnn=c(TRUE,FALSE)),by="TipAnn") %>%
  mutate(Count=replace_na(Count,0)) %>% arrange(TipAnn) %>%
  group_by %>% summarise(
    NodeID=NNN,
    Bias=Count[TipAnn]/sum(Count),
    Background=BBBackground %>% filter(TipAnn) %>% .$Freq,
    pval=stats::chisq.test(Count,p=BBBackground$Freq)$p.value
  )
}
