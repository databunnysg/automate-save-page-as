# ranking<-readRDS("chinesetop500categorized")
# for(i in 1:nrow(ranking))
# {
#   if(file.exists(paste0("/mnt/webdownload/",ranking[i,]$channelid))) next
#   cmd<-paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/channel/",ranking[i,]$channelid,"/videos -b firefox -d /mnt/webdownload/",ranking[i,]$channelid)
#   system(cmd)
#   cat(paste(cmd,"\n"))
#   #Sys.sleep(2)
# }

library(redux)
library(jsonlite)
if(!exists("lconfig"))
{
  lconfig<-redis_config(host="10.0.1.10",port="7001")
  l<-hiredis(lconfig)
  l$AUTH("REDISHOST")
  l$SELECT(5)
  l$PING()
}

if(FALSE)
{
  #THIS CODE USED FOR GENERATE TEST RECORD
  videocommentstask<-data.frame(videoid="XE3KWaqrOcY",force=TRUE,pagedown=0,savewaittime=3,stringsAsFactors = FALSE)
  l$RPUSH("youtubevideocomments",toJSON(videocommentstask))
}


while(TRUE)
{
  pr<-l$RPOP("youtubevideocomments")
  if(is.null(pr))
  {
    Sys.sleep(1)
    next
  }
  videoobj<-fromJSON(pr)
  for(i in 1:nrow(videoobj))
  {
    if(!videoobj[i,]$force&&file.exists(paste0("/mnt/webdownload/",videoobj[i,]$videoid))) next
    cmd<-paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/watch?v=",videoobj[i,]$videoid," -b firefox -d /mnt/webdownload/",videoobj[i,]$videoid," --pagedown ",videoobj[i,]$pagedown," --savewaittime ",videoobj[i,]$savewaittime)
    system(cmd)
    Sys.sleep(1)
    system("sudo pkill -f firefox")
    cat(paste(cmd,"\n"))
    #Sys.sleep(as.numeric(videoobj[i,]$pagedown)+as.numeric(videoobj[i,]$savewaittime)+3)
  }
}
