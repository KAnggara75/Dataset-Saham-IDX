#!/bin/bash

# Konfigurasi
START_DATE="2019-07-29"
END_DATE=$(date +%Y-%m-%d)
FOLDER="Saham/Semua"
PARALLEL_LIMIT=100 # Jumlah download paralel sekaligus

# Memastikan direktori tujuan ada
mkdir -p "$FOLDER"

echo "------------------------------------------"
echo "Memulai update paralel (Max: $PARALLEL_LIMIT)..."
echo "Rentang: ${START_DATE} s/d ${END_DATE}"
echo "------------------------------------------"

count=0
for file in "$FOLDER"/*.csv; do
    # Lewati jika bukan file
    [ -e "$file" ] || continue
    
    # Ambil nama file tanpa ekstensi sebagai ticker/symbol
    SYMBOL=$(basename "$file" .csv)
    
    # Jalankan curl di background
    (
        echo "Fetch: ${SYMBOL}"
        curl -s --location "localhost:3000/api/v1/stocks/${SYMBOL}/history?output=csv&fields=date,previous,open_price,first_trade,high,low,close,change,volume,value,frequency,index_individual,offer,offer_volume,bid,bid_volume,listed_shares,tradeble_shares,weight_for_index,foreign_sell,foreign_buy,delisting_date,non_regular_volume,non_regular_value,non_regular_frequency&start_date=${START_DATE}&end_date=${END_DATE}" > "$file"
    ) &

    # Batasi jumlah proses background agar tidak membebani server/sistem
    ((count++))
    if (( count % PARALLEL_LIMIT == 0 )); then
        wait
        echo "--- Batch selesai, lanjut ke batch berikutnya... ---"
    fi
done

# Tunggu semua proses sisa selesai
wait

echo "------------------------------------------"
echo "Download selesai. Melakukan commit..."

# Git add dan commit sekaligus setelah semua selesai
git add "$FOLDER"/*.csv
git commit -m "update: history all tickers up to ${END_DATE}"

echo "------------------------------------------"
echo "Selesai! Semua data di ${FOLDER} telah diperbarui dan di-commit."
