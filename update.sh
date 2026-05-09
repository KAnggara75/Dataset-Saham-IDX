#!/bin/bash

# Argumen 2: Ticker/Symbol (AADI)
# Argumen 1: Tanggal Mulai (YYYY-MM-DD)
SYMBOL=$2
START_DATE=$1
END_DATE=$(date +%Y-%m-%d)

if [ -z "$SYMBOL" ] || [ -z "$START_DATE" ]; then
    echo "Usage: $0 <SYMBOL> <START_DATE>"
    echo "Example: $0 AADI 2019-07-29"
    exit 1
fi

# Memastikan direktori tujuan ada
mkdir -p Saham/Semua

echo "Mengunduh data riwayat saham untuk ${SYMBOL}..."
echo "Rentang: ${START_DATE} s/d ${END_DATE}"

# Eksekusi curl
curl --location "localhost:3000/api/v1/stocks/${SYMBOL}/history?output=csv&fields=date,previous,open_price,first_trade,high,low,close,change,volume,value,frequency,index_individual,offer,offer_volume,bid,bid_volume,listed_shares,tradeble_shares,weight_for_index,foreign_sell,foreign_buy,delisting_date,non_regular_volume,non_regular_value,non_regular_frequency&start_date=${START_DATE}&end_date=${END_DATE}" > "Saham/Semua/${SYMBOL}.csv"

echo "Selesai! Data disimpan di Saham/Semua/${SYMBOL}.csv"
