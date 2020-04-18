if [ ! -f "game.conf" ]; then
	echo "Run command from CTW games/CTW/"
	exit 1
fi

if [[ "$#" -ne 1 ]]; then
	echo "USAGE: ./build/create_worldbuilder.sh worldname"
	exit 1
fi

worldname=$1

echo Creating world $worldname

pushd ../../

if [[ -d "worlds/$worldname" ]]; then
	echo "World '$worldname' already exists"
	exit 1
fi

mkdir "worlds/$worldname"
pushd "worlds/$worldname"

echo "backend = sqlite3" > world.mt
echo "gameid = minetest" >> world.mt

echo "seed = 12151467688261457958" > map_meta.txt
echo "mg_name = singlenode" >> map_meta.txt
echo "chunksize = 5" >> map_meta.txt
echo "[end_of_params]" >> map_meta.txt

mkdir worldmods
pushd worldmods

addmod() {
	ln -s ../../../games/CTW/$2/$1 $1
}

addmod mods/ctw world
addmod mods/ctw books
addmod mods homedecor
addmod furnishings
addmod bakedclay

popd

echo $PWD

cp worldmods/world/schematics/world.conf world.conf
cp worldmods/world/schematics/world.mts load_world.mts
