#!/bin/bash
APP_NAME="VSC"
APP_FUZZY_NAME="VScript Compiler"
APP_VERSION="0.1 beta"

#Pregenerated code ahead. Here be dragons?
VS_VERSION=1.2
VS_CODENAME="Cayenne"

#Pregenerated code ahead. Here be dragons?
if [ "$1" == "-h" ]
then
  echo "VScript Version $VS_VERSION $VS_CODENAME"
fi
dump(){
echo "Crash Dump"
echo "VScript Version: $VS_VERSION $VS_CODENAME"
echo "Loaded Libraries:"
for lib in $loadedLibs
do
echo -ne $lib
done

echo
echo "Loaded Modules:"
for mod in $loadedMods
do
echo -ne $mod
done

echo
echo "Variables:"
for var in $vars
do
echo -ne $var
done

echo
echo -e "\nApp metadata:"
echo "  App name: $APP_NAME"
echo "  App display name: $APP_FUZZY_NAME"
echo "  App version: $APP_VERSION"
}
throw(){
echo "ERROR: $1 in program $APP_NAME"
echo "Error Detected... Dumping program data"
dump
exit 1
}
var(){
vars="$vars\n$1"
eval "$1"
}
loadedLibs="$loadedLibs\ncore V1.0: VScript Core Module"

# end of library core 

VSC.compileSource(){
 # If we are doing a single file compile
 if ! [ -f build.conf ]
 then
  SRC_FILE=${1%.*}
  rm $SRC_FILE.vsa    
  # Import Handling
  # Get all imports from file after making sure that we have imports.
  if [ "$(VSC.getImports $SRC_FILE.vss)" != "" ]
  then
   for import in $(VSC.getImports "$SRC_FILE".vss) 
   do
    # If the import actually exists
    if resolveImport "$import"
    then
     # Capture the import location, Write down that we found it, and if we haven't already imported it then import it into the class
     IMPORT_LOC = $(VSC.resolveImportPath "$import")
     if ! $(echo $ADDEDIMPORTS | grep $import)
     then 
      ADDEDIMPORTS = "$ADDEDIMPORTS $import"
      cat $IMPORT_LOC >> $SRC_FILE.vsa
     fi
    fi
   done
  fi
  
  cp $SRC_FILE.vss $SRC_FILE.vsa

  echo "loadedLibs=\"$(echo $ADDEDIMPORTS | tr " " "\n")\"" >> $SRC_FILE.vsa
  echo "loadedMods=\"n/a due to VSC compilation\"" >> $SRC_FILE.vsa

  echo 'if [ "$1" != "--getdata" ]' >> $SRC_FILE.vsa
  echo 'then' >> $SRC_FILE.vsa
  echo 'main $@' >> $SRC_FILE.vsa
  echo 'fi' >> $SRC_FILE.vsa


  # Remove all comments from output class
  sed -i '/^#/d' $SRC_FILE.vsa
  sed -i '/^\<package\>/d' $SRC_FILE.vsa
 #if we are doing a project compile
 else 
  SRC_FILE=$VSC_PROG_NAME

  # Import Handling
  # Get all imports from file after making sure that we have imports.
  if [ "$(VSC.getImports $SRC_FILE)" != "" ]
  then
   for import in $(VSC.getImports "$SRC_FILE") 
   do
    # If the import actually exists
    if resolveImport "$import"
    then
     # Capture the import location, Write down that we found it, and if we haven't already imported it then import it into the class
     IMPORT_LOC = $(VSC.resolveImportPath "$import")
     if ! $(echo $ADDEDIMPORTS | grep $import)
     then 
     ADDEDIMPORTS = "$ADDEDIMPORTS $import"
     cat $IMPORT_LOC >> $VSC_PROG_NAME.vsa
     fi
    fi
   done
  fi

  # Remove all comments from output class
  sed -i '/^\<package\>/d' $SRC_FILE.vsa
  sed -i '/^#/d' $VSC_PROG_NAME.vsa    
  echo "loadedLibs=\"$(echo $ADDEDIMPORTS | tr " " "\n")\"" >> $SRC_FILE.vsa
  echo "loadedMods=\"n/a due to VSC compilation\"" >> $SRC_FILE.vsa

  echo 'if [ "$1" != "--getdata" ]' >> $SRC_FILE.vsa
  echo 'then' >> $SRC_FILE.vsa
  echo 'main $@' >> $SRC_FILE.vsa
  echo 'fi' >> $SRC_FILE.vsa

 fi
}
VSC.getImports(){
echo $(grep '^import.' $1 | sed 's/import //g')
}
VSC.getPackage(){
echo $(grep '^package.' $1 | sed 's/package //g')
}
VSC.loadConfig(){
 # Default Configuration
 VSC_LIB_PATH=/usr/lib/VScript/libs
 VSC_PROG_NAME="Untitled-VSC-Application"
 VSC_PROG_TYPE="app"

 # Load System Configuration
 if [ -e /etc/VScript/$VS_VERSION/VSC-build.conf ]
 then 
 source /etc/VScript/$VS_VERSION/VSC-build.conf
 fi

 # Project Config
 if [ -e ./build.conf ]
 then
  LIBPATHOLD=$VSC_LIB_PATH
  source ./build.conf  
  $VSC_LIB_PATH="$LIBPATHOLD $VSC_LIB_PATH"
 else
  echo "Missing build.conf: using default config"
 fi
 echo "Loaded Configuration"
}
main(){
 echo "Welcome to $APP_FUZZY_NAME $APP_VERSION"
 echo "loading configuration for $APP_NAME"
 VSC.loadConfig
 
 if [ -f "build.conf" ] && [ $# == 0 ] || [ "$1" == "-p" ]
 then
  VSC.projectCompile
  echo "Finished Compiling $VSC_PROG_NAME"
 else
  if [ $# > 1 ]
  then 
   if [ $1 == "-I" ]
   then
    if [ -d "$2" ]
    then
     VSC_LIB_PATH=$2
    fi
   fi
   VSC.compileSource "${@: -1}"
  else
   VSC.compileSource $1
  fi
  echo "Finished Compiling $1"
 fi
}
VSC.projectCompile(){
 echo "Build Configuration Found... Compiling Project"
 for f in $(ls $VSC_SRC_LOCATION/*.vss)
 do
  compileSource $f
 done
}
resolveImport(){
 if [ "$1" == "" ]
 then
  throw "no import name specified in VSC:resolveImport"
  return 1
 fi

 for loc in $VSC_LIB_PATH
 do
  if [ -f "$loc/$1.vsl"]
  then
   return 0
  fi
 done
 throw "invalid import: $1 in VSC:resolveImport"
}
resolveImport(){
 if [ "$1" == "" ]
 then
  throw "no import name specified in VSC:resolveImportPath"
  return 1
 fi

 for loc in $VSC_LIB_PATH
 do
  if [ -f "$loc/$1.vsl"]
  then
   echo $loc/$1.vsl
   return 0
  fi
 done
 throw "invalid import: $1 in VSC:resolveImportPath"
}
if [ "$1" != "--getdata" ]
then
main $@
fi
