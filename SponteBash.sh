  #!/bin/bash

  # <branch>[dev || stag] <name-branch> <app>[edu || med]
  cd frontend

  if [ -s $1 ];
    then {
      echo "Faltou comando de branch.";
      exit;
    };
    fi


  if [ $1 == "dev" ] ;
  then 
  {
    git checkout develop;
    git pull origin develop;
    yarn build:libs
    yarn app-medplus build:development:apis;
    yarn app-educacional build:development:apis;
      if [ $2 ] ;
        then {
          git checkout -b "feature/$2";
        };
      fi
  }
  fi

  if [ $1 == "stag" ] ;
  then 
  {
    git checkout staging;
    git pull origin staging;
    yarn build:libs
    yarn app-medplus build:staging:apis;
    yarn app-educacional build:staging:apis;
    if [ $2 ] ;
        then {
          git checkout -b "bugfix/$2";
        };
      fi
  }
  fi

  if [ -s $3 ] ; 
    then {
      exit;
    }
    fi

  nohup yarn dev:libs > /dev/null &
  
  if [ $3 == "med" ] ;
    then {
      yarn app-medplus start
    };
  fi
 
  if [ $3 == "edu" ] ;
    then {
      yarn app-educacional start
    };
  fi