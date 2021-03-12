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
library(fs)
library(readr)
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
  Sys.sleep(1)
  try(
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
        try(
          {
            tmpfolder<-paste0("TMP",sample(10000:90000,1))
            try(dir_create(paste0("/mnt/webdownload/firefox/",tmpfolder)))
            if(!videoobj[i,]$force&&file.exists(paste0("/mnt/webdownload/",videoobj[i,]$videoid))) next
            cmd<-paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/watch?v=",videoobj[i,]$videoid," -b firefox -d /mnt/webdownload/firefox/",tmpfolder,"/",videoobj[i,]$videoid," --pagedown ",videoobj[i,]$pagedown," --savewaittime ",videoobj[i,]$savewaittime)
            system(cmd)
            Sys.sleep(5)
            fi<-file_info(paste0("/mnt/webdownload/firefox/",tmpfolder,"/",videoobj[i,]$videoid))
            if(fi$size>1000000) file_copy(paste0("/mnt/webdownload/firefox/",tmpfolder,"/",videoobj[i,]$videoid),paste0("/mnt/webdownload/",videoobj[i,]$videoid))
            if(fi$size<=500000)
            {
              fic<-read_file(paste0("/mnt/webdownload/firefox/",tmpfolder,"/",videoobj[i,]$videoid),paste0("/mnt/webdownload/",videoobj[i,]$videoid))
              #fic<-read_file(paste0("Z:/webdownload/firefox/TMP87422/LgPIOHfs74c"))
              if(grepl("Our systems have detected unusual traffic from your computer network",fic)) system("sudo pkill -9 -f comments")
            }
            dir_delete(paste0("/mnt/webdownload/firefox/",tmpfolder))
            system("sudo pkill -9 -f firefox")
            system("sudo pkill -9 -f save_page_as")
            cat(paste(cmd,"\n"))
            #Sys.sleep(as.numeric(videoobj[i,]$pagedown)+as.numeric(videoobj[i,]$savewaittime)+3)
          }
        )
      }
    }
  )
}
