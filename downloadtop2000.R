ranking<-readRDS("chinesetop500categorized")
for(i in 1:nrow(ranking))
{
  if(file.exists(paste0("/mnt/webdownload/",ranking[i,]$channelid))) next
  cmd<-paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/channel/",ranking[i,]$channelid,"/videos -b firefox -d /mnt/webdownload/",ranking[i,]$channelid)
  system(cmd)
  cat(paste(cmd,"\n"))
  #Sys.sleep(2)
}
