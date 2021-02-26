ranking<-readRDS("chinesetop500categorized")
for(i in 1:nrow(ranking))
{
  if(file.exists(paste0("/mnt/webdownload/",ranking[i,]$channelid))) next
  cmd<-paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/channel/",ranking[i,]$channelid,"/videos -b firefox -d /mnt/webdownload/",ranking[i,]$channelid)
  system(cmd)
  cat(paste(cmd,"\n"))
  #Sys.sleep(2)
}

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

#channel<-data.frame(channelid="UCPcF3KTqhD67ADkukx_OeDg",force=FALSE,pagedown=20,stringsAsFactors = FALSE)
#l$RPUSH("youtubechannelloadtask",toJSON(channel))

while(TRUE)
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
    if(channelobj[i,]$force&&file.exists(paste0("/mnt/webdownload/",channelobj[i,]$channelid))) next
    cmd<-paste0("/home/root/automate-save-page-as/save_page_as https://www.youtube.com/channel/",channelobj[i,]$channelid,"/videos -b firefox -d /mnt/webdownload/",channelobj[i,]$channelid," --pagedown ",channelobj[i,]$pagedown)
    system(cmd)
    cat(paste(cmd,"\n"))
    #Sys.sleep(2)
  }
}
