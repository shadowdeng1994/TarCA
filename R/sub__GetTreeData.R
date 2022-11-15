### Get tree data
fun.GetTreeData <- function(TTTree){
    ggtree::ggtree(TTTree)$data
}