./build.sh

result=$?

if [ "$result" -ne 0 ]; then
    exit $result
fi

cp pkg/* bin/

mkdir -p pkgbin/
rm -rf pkgbin/*
mkdir -p pkgbin/SteamDeckGyroDSUSetup
cp bin/* pkgbin/SteamDeckGyroDSUSetup/

cd pkgbin
zip -r SteamDeckGyroDSUSetup.zip SteamDeckGyroDSUSetup
rm -rf SteamDeckGyroDSUSetup