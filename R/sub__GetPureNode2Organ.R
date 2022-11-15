#### Get PureNode2Organ file
fun.GetPureNode2Organ <- function(PPPureNode,AAAnn){
    PPPureNode %>%
    right_join(AAAnn,by=c("TipAnn","TipLabel")) %>%
    group_by(TipLabel) %>% mutate(Parent=replace_na(Parent,TipLabel)) %>%
    group_by(Parent,TipAnn) %>% summarise(Count=n()) %>%
    arrange(TipAnn,Count)
}
