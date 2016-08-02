#!/bin/bash
G_ZONE="asia-east1-b"
gcloud dataproc clusters create raas-system --zone ${G_ZONE} --initialization-action-timeout 60m --master-machine-type n1-standard-2 --master-boot-disk-size 50 --num-workers 3 --worker-machine-type n1-standard-4 --num-preemptible-workers 3  --worker-boot-disk-size 50 --project venraasitri --initialization-actions 'gs://raas_system_venraasitri/initroot.sh'
yes_date=$(date --date="yesterday" +"%Y%m%d")
gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo bash /root/VenOfflineModule/Modules/RaaS_System_Module/process/daily_weblog_process_gs.sh'
gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo /root/batch_data_ingestion/venraas/batch_data_download/gocc/run-sync.sh'
# gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'mkdir -p ~/VenOfflineModule/Data_Center/gohappy_MarketInfo_Data/'
# gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'mkdir -p ~/VenOfflineModule/Data_Center/gohappy_OrderList_Data/'
# gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo cp /tmp/*_gocc/data/GoodsCateCode.tsv ~/VenOfflineModule/Data_Center/gohappy_MarketInfo_Data/'
# gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo cp /tmp/*_gocc/data/Category.tsv ~/VenOfflineModule/Data_Center/gohappy_MarketInfo_Data/'
# gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo cp /tmp/*_gocc/data/OrderList_${yes_date}.tsv ~/VenOfflineModule/Data_Center/gohappy_OrderList_Data/'
# gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo cp /tmp/*_gocc/data/Goods.tsv ~/VenOfflineModule/Data_Center/gohappy_MarketInfo_Data/'
gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo gsutil cp gs://raas_system_venraasitri/daily_model_output/*.tsv /root/venraas_daily_data/daily_model_output'
gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo bash /root/VenOfflineModule/Modules/RaaS_System_Module/process/daily_company_process.sh'
gcloud compute ssh raas-system-m --zone ${G_ZONE} -t --command 'sudo gsutil cp -r /root/venraas_daily_data/daily_model_output gs://raas_system_venraasitri'
gsutil cp gs://raas_system_venraasitri/daily_model_output/all_TP_dump.tsv /home/n668892000/daily_model_output
#yes | gcloud dataproc clusters delete raas-system

# psql -h postgresql-1 -p 5432 -a -U itri -w -f importtsv2postgresql.sql
