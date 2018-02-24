user="uhitzel"
playlist="6iCAQD1aQOGlZnws0ApuLy"
token=""

out=/tmp/spotify.$$.tmp
curl -s -o $out.i -X GET "https://api.spotify.com/v1/users/$user/playlists/$playlist" -H "Authorization: Bearer $token" -H 'Cache-Control: no-cache'

name=$(cat $out.i | jq ".name")
descr=$(cat $out.i | jq ".description")
url=$(cat $out.i | jq ".external_urls[]")
owner=$(cat $out.i | jq ".owner.display_name")

# pagination - 200 tracks max
curl -s -o $out.1 -X GET "https://api.spotify.com/v1/users/$user/playlists/$playlist/tracks?offset=0&limit=100" -H "Authorization: Bearer $token" -H 'Cache-Control: no-cache'

cat $out.1 | jq '.items[].track.id' | tr -d '"' > $out.1.ids

curl -s -o $out.2 -X GET "https://api.spotify.com/v1/users/$user/playlists/$playlist/tracks?offset=100&limit=100" -H "Authorization: Bearer $token" -H 'Cache-Control: no-cache'

cat $out.2 | jq '.items[].track.id' | tr -d '"' > $out.2.ids

num_ids=$(cat $out.*.ids | wc -l)

# get audio features

ids=$(cat $out.1.ids | tr "\n" "," | sed "s/,$//;")
curl -s -o $out.f.1 -X GET "https://api.spotify.com/v1/audio-features?ids=$ids" -H "Authorization: Bearer $token" -H 'Cache-Control: no-cache'

ids=$(cat $out.2.ids | tr "\n" "," | sed "s/,$//;")
curl -s -o $out.f.2 -X GET "https://api.spotify.com/v1/audio-features?ids=$ids" -H "Authorization: Bearer $token" -H 'Cache-Control: no-cache'

cat $out.1 | jq ".items[]" > $out.items
cat $out.2 | jq ".items[]" >> $out.items

echo "Playlist: $user/$playlist"
echo "Name: $name"
echo "Owner: $owner"
echo "Description: $descr"
echo "URL: $url"
echo "# of tracks: $num_ids tracks"

# acousticness
cat $out.f.* | jq '.audio_features[].acousticness' > $out.acousticness
echo "acousticness: $(python means.py $out.acousticness)"

# danceability
cat $out.f.* | jq '.audio_features[].danceability' > $out.danceability
echo "danceability: $(python means.py $out.danceability)"

# energy
cat $out.f.* | jq '.audio_features[].energy' > $out.energy
echo "energy: $(python means.py $out.energy)"

# instrumentalness
cat $out.f.* | jq '.audio_features[].instrumentalness' > $out.instrumentalness
echo "instrumentalness: $(python means.py $out.instrumentalness)"

# liveness
cat $out.f.* | jq '.audio_features[].liveness' > $out.liveness
echo "Liveness: $(python means.py $out.liveness)"

# loudness
cat $out.f.* | jq '.audio_features[].loudness' > $out.loudness
echo "Loudness: $(python means.py $out.loudness) dB"

# speechiness
cat $out.f.* | jq '.audio_features[].speechiness' > $out.speechiness
echo "Speechiness: $(python means.py $out.speechiness)"

# tempo
cat $out.f.* | jq '.audio_features[].tempo' > $out.tempo
echo "Tempo: $(python means.py $out.tempo) bpm"
