  #!/bin/bash

  # yarn flow - volta pra develop e atualiza com a origin
  # staging - altera a branch pra staging, se não informado ela é develop
  # build - builda as libs e os dois apps de acordo com a branch, padrão é develop
  # app-medplus ou app-educacional - ele starta as libs em modo assistido e o projeto no terminal
  # -b nome-da-branch - cria e dá checkout pra branch dentro dos padrões do git flow
  # --finish - Envia a branch corrente pra origin
  # --no-pull - Não atualiza a branch com origin
  # --no-checkout - Não volta pra develop ou staging/ Bom pra atualizar a branch corrente com a origin e buildar o projeto
  # --delete-merged - Deleta todas as branchs locais que já foram mergidas

  branchOrigin=develop

  for arg in "$@"
    do
      if [[ "$arg" = "staging" ]]; then
        branchOrigin=staging
        continue
      fi
      
      if [[ "$arg" = "-b" ]]; then
        branchParams=true
        continue
      fi

      if [[ "$arg" = "build" ]]; then
        build=true
        continue
      fi

      if [[ "$arg" = "app-medplus" ]]; then
        app=app-medplus
        continue
      fi

      if [[ "$arg" = "app-educacional" ]]; then
        app=app-educacional
        continue
      fi

      if [[ "$arg" = "--no-pull" ]]; then
        noPull=true
        continue
      fi

      if [[ "$arg" = "--finish" ]]; then
        finish=true
        continue
      fi

      if [[ "$arg" = "--no-checkout" ]]; then
        noCheckout=true
        continue
      fi

      if [[ "$branchParams" = "true" ]]; then
        newBranch=$arg
        continue
      fi
      
      if [[ "$arg" = "--delete-merged" ]]; then
        deleteBranchsMergeds=true
        continue
      fi
    done

  if [[ $deleteBranchsMergeds ]]; then
    branchsMergeds=`git branch --merged | grep -E "feat|feature|bugfix"`

    for branch in $branchsMergeds
      do {
        echo $branch
        git branch -d $branch
      }
      done
  fi

  if [[ $branchParams && ! $newBranch ]]; then {
    echo "Comando -b exige nome de branch como parâmetro.";
    exit;
  } fi
  
  if [[ $finish ]]; then {
    currentBranch=`git status | grep -E "bugfix|feature|feat" |  sed 's/.*ramo //'`

    if [[ ! $currentBranch ]]; then {
        echo "Sua branch não é uma bugfix, feat, ou feature. Não foi feito o push pra origin.";
        exit;
      } fi

    git push origin $currentBranch
  } fi


  if [[ ! $noCheckout ]]; then {
    git checkout $branchOrigin;
    currentBranch=`git status | grep -o $branchOrigin`      
  } fi

  if [[ ! $currentBranch = $branchOrigin && ! $noCheckout ]]; then {
      echo "Você teve problemas ao efetuar o checkout. Confira as alterações no seu repositório local.";
      exit;
  } fi
  
  if [[ ! $noPull ]]; then {
      git pull origin $branchOrigin;      
  } fi

  if [[ $build ]]; then {
    if [[ "$branchOrigin" = "staging" ]]; then
      branchApis=staging
    else {
      branchApis=development
    } fi

      yarn build:libs
      yarn app-medplus build:$branchApis:apis;
      yarn app-educacional build:$branchApis:apis;
    } fi
  
  if [[ $newBranch ]]; then {
    if [[ "$branchOrigin" = "staging" ]]; then
      typeBranch=bugfix
    else {
      typeBranch=feature
    } fi
      git checkout -b $typeBranch/$newBranch
    } fi

  if [[ $app ]]; then {
      nohup yarn dev:libs > /dev/null &
      yarn $app start
    } fi
  
  exit

