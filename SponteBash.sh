  #!/usr/bin/env bash
  # set -e

  # yarn flow - volta pra develop e atualiza com a origin
  # staging - altera a branch pra staging, se não informado ela é develop
  # pre-master - altera a branch pra pre-master, se não informado ela é develop
  # build - builda as libs e os dois apps de acordo com a branch, padrão é develop
  # app-medplus ou app-educacional - ele starta as libs em modo assistido e o projeto no terminal
  # -b nome-da-branch - cria e dá checkout pra branch dentro dos padrões do git flow
  # --finish - Envia a branch corrente pra origin
  # --no-pull - Não atualiza a branch com origin
  # --no-checkout - Não volta pra develop ou staging/ Bom pra atualizar a branch corrente com a origin e buildar o projeto
  # --delete-merged - Deleta todas as branchs locais que já foram mergidas

  branchOrigin=develop
  branchApis=development
  typeBranch=feature

  declare -a allApps=(app-educacional app-educacional-portal-aluno app-educacional-teste-gratis app-medplus app-medplus-meet app-medplus-portal-agendamento app-medplus-teste-gratis app-retaguarda-educacao app-retaguarda-saude)

  for arg in "$@"
    do
      if [[ "$arg" = "staging" || "$arg" = "-tst" ]]; then
        branchOrigin=staging
        branchApis=staging
        typeBranch=bugfix
        continue
      fi

      if [[ "$arg" = "pre-master" || "$arg" = "-demo" ]]; then
        branchOrigin=pre-master
        branchApis=demo
        typeBranch=hotfix
        continue
      fi
      
      if [[ "$arg" = "-b" ]]; then
        branchParams=true
        continue
      fi

      if [[ "$arg" = "build" || "$arg" = "-bl" ]]; then
        build=true
        continue
      fi

      if [[ "$arg" = "app-medplus" || "$arg" = "-med" ]]; then
        app=app-medplus
        continue
      fi

      if [[ "$arg" = "app-educacional" || "$arg" = "-edu" ]]; then
        app=app-educacional
        continue
      fi

      if [[ "$arg" = "app-educacional-portal-aluno" || "$arg" = "-edu-portal" ]]; then
        app=app-educacional-portal-aluno
        continue
      fi

      if [[ "$arg" = "app-educacional-teste-gratis" || "$arg" = "-edu-gratis" ]]; then
        app=app-educacional-teste-gratis
        continue
      fi 

      if [[ "$arg" = "app-medplus-meet" || "$arg" = "-med-meet" ]]; then
        app=app-medplus-meet
        continue
      fi 

      if [[ "$arg" = "app-medplus-portal-agendamento" || "$arg" = "-med-portal" ]]; then
        app=app-medplus-portal-agendamento
        continue
      fi 

      if [[ "$arg" = "app-medplus-teste-gratis" || "$arg" = "-med-gratis" ]]; then
        app=app-medplus-teste-gratis
        continue
      fi

      if [[ "$arg" = "app-retaguarda-educacao" || "$arg" = "-ret-edu" ]]; then
        app=app-retaguarda-educacao
        continue
      fi

      if [[ "$arg" = "app-retaguarda-saude" || "$arg" = "-ret-edu" ]]; then
        app=app-retaguarda-saude
        continue
      fi


      if [[ "$arg" = "--no-pull" || "$arg" = "-np" ]]; then
        noPull=true
        continue
      fi

      if [[ "$arg" = "--finish" || "$arg" = "-f" ]]; then
        finish=true
        continue
      fi

      if [[ "$arg" = "--no-checkout"  || "$arg" = "-nc" ]]; then
        noCheckout=true
        continue
      fi

      
      if [[ "$arg" = "--delete-merged" || "$arg" = "-dm" ]]; then
        deleteBranchsMergeds=true
        continue
      fi

      if [[ "$arg" = "--all" ]]; then
        allBuildsApis=true
        continue
      fi
      
      if [[ "$branchParams" = "true" ]]; then
        newBranch=$arg
        branchParams=false
        continue
      fi

      echo "Comando $arg está com uso incorreto ou não existe."
      exit;
    done
  
    if [[ $branchParams && ! $newBranch ]]; then {
    echo "Comando -b exige nome de branch como parâmetro.";
    exit;
  } fi
  
  if [[ $finish ]]; then {
    currentBranch=`git status | grep -E "bugfix|feature|feat|hotfix|fix" |  sed "s/.*On branch //"`
    
    if [[ ! $currentBranch ]]; then {
      echo "Sua branch não é uma bugfix, hotfix, ou feature. Não foi feito o push pra origin.";
      exit;
    } fi

    git push origin $currentBranch
  } fi


  if [[ ! $noCheckout ]]; then {
    git checkout $branchOrigin;
    currentBranch=`git status | grep -m1 -o $branchOrigin`
  } fi

  if [[ ! $currentBranch = $branchOrigin && ! $noCheckout ]]; then {
      echo "Você teve problemas ao efetuar o checkout. Confira as alterações no seu repositório local. Sua branch é $currentBranch e seu destino é $branchOrigin";
      exit;
  } fi
  
  if [[ ! $noPull ]]; then {
      git pull origin $branchOrigin;      
  } fi

  if [[ $deleteBranchsMergeds ]]; then
    branchsMergeds=`git branch --merged | grep -E "feat|feature|bugfix|hotfix|fix"`

    for branch in $branchsMergeds
      do {
        git branch -d $branch
      }
      done
  fi

  if [[ $build ]]; then {
    yarn;
    yarn build:libs;    
  } fi

  if [[ $allBuildsApis ]]; then 
    for apps in "${allApps[@]}"
      do {        
        yarn $apps build:$branchApis:apis
      }
      done
  fi
  
  if [[ $newBranch ]]; then {
      git checkout -b $typeBranch/$newBranch
  } fi

  if [[ $app ]]; then {
    nohup yarn dev:libs > /dev/null &
    yarn $app start:$branchApis
  } fi
  
  exit

