#### Get Clade detail
fun.GetCladeSizeDetail <- function(PPPureNode2Organ){
    PPPureNode2Organ %>% 
    group_by(TipAnn,Count) %>% summarise(CCC=n()) %>% 
    arrange(TipAnn,Count) %>% 
    group_by %>% mutate(BinFreq=paste0(Count," (",CCC,")")) %>% 
    group_by(TipAnn) %>% summarise(CladeSize=paste(BinFreq,collapse = ", "))
}