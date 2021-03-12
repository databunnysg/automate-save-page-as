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
  channel<-data.frame(channelid="UCzUfFcCFtVoGdzIvk8iGvFw",force=TRUE,pagedown=50,savewaittime=20,stringsAsFactors = FALSE)
  l$RPUSH("youtubechannelloadtask",toJSON(channel))
}


while(TRUE)
{
  try(
    {
      pr<-l$RPOP("youtubechannelloadtask")
      if(is.null(pr))
      {
        Sys.sleep(1)
        next
      }
      channelobj<-fromJSON(pr)
      for(i in 1:nrow(channelobj))
      {
        if(!channelobj[i,]$force&&file.exists(paste0("/mnt/webdownload/",channelobj[i,]$channelid))) next
        cmd<-paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/channel/",channelobj[i,]$channelid,"/videos -b firefox -d /mnt/webdownload/firefox/",channelobj[i,]$channelid," --pagedown ",channelobj[i,]$pagedown," --savewaittime ",channelobj[i,]$savewaittime)
        system(cmd)
        cat(paste(cmd,"\n"))
        Sys.sleep(10)
        if(!file_exists(paste0("/mnt/webdownload/firefox/",channelobj[i,]$channelid))) next
        fi<-file_info(paste0("/mnt/webdownload/firefox/",channelobj[i,]$channelid))
        fi<-file_info(paste0("z:/webdownload/8d-oB52v7p4"))
        if(fi$size>1000000) file_copy(paste0("/mnt/webdownload/firefox/",channelobj[i,]$channelid),paste0("/mnt/webdownload/",channelobj[i,]$channelid))
        system("sudo pkill -f firefox")
        system("sudo pkill -9 -f save_page_as")
        #Sys.sleep(2)
      }
    }
  )

}
