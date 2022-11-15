#### Get EffN file
fun.GetEffN <- function(PPPureNode2Organ){
    PPPureNode2Organ %>% 
    mutate(C_2inN=Count*(Count-1)/2) %>% 
    group_by(TipAnn) %>% summarise(I_num=sum(C_2inN),Total=sum(Count)) %>% 
    mutate(I_deno=Total*(Total-1)/2) %>% 
    mutate(I_index=I_num/I_deno) %>% 
    arrange(I_index) %>% 
    mutate(EffN=1/I_index) %>% 
    select(TipAnn,Total,EffN) %>% 
    arrange(-EffN)
}