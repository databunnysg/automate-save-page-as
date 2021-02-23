ranking<-readRDS("chinesetop500categorized")
#for(i in 1:nrow(ranking))
i<-1
{
  system(paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/channel/",ranking[i,]$channelid,"/videos -b firefox -d /mnt/webdownload/",ranking[i,]$channelid))
  Sys.sleep(120)
}
