#!/bin/sh

hint_when_GUC_params_changed() {
  lt_ctl status | grep -q PID || return
  context=$(ltsql -c "select context from pg_settings where name = '$1';" -P "tuples_only=on" | awk '{print $NF}')
  case $context in
    sighup)
    echo -e "\033[1;31mYou need to execute 'reload' command now!\033[0m"
    ;;
    postmaster)
    echo -e "\033[1;31mYou need to execute 'restart' command now!\033[0m"
    ;;
    *)
    echo -e "\033[1;31m\`$1' GUC param is in context \`$context'\033[0m"
    ;;
  esac
}

node() {
  case $1 in
    initdb)
    initdb

    # enable 'canopy' extension
    sed -i "s/^#shared_preload_libraries = '/shared_preload_libraries = 'canopy,/" $LTDATA/lightdb.conf
    sed -i "s/,lt_statement_rollback//" $LTDATA/lightdb.conf
    ;;
    start)
    lt_ctl start > `pwd`/running.log 2>&1
    lt_ctl status
    ;;
    stop)
    lt_ctl stop > `pwd`/stop.log 2>&1
    ;;
    status)
    lt_ctl status
    ;;
    restart)
    lt_ctl restart
    ;;
    reload)
    lt_ctl reload
    ;;
    config)
      confile=$LTDATA/lightdb.conf
      case $2 in
        *-=*)
        echo "pop value"
        key=$(echo "$2" | awk -F '-=' '{print $1}')
        value=$(echo "$2" | awk -F '-=' '{print $2}')
        line=$(grep -m 1 "$key.*=" $confile)
        if [ -n "$line" ]; then
          new_value=$(echo $line | cut -d= -f2 | sed "s/$value//")
          sed -i "/$key.*=/d" $confile
          echo "$key = $new_value" >> $confile

          hint_when_GUC_params_changed $key
        fi
        ;;
        *+=*)
        echo "prepend value"
        key=$(echo "$2" | awk -F '+=' '{print $1}')
        value=$(echo "$2" | awk -F '+=' '{print $2}')
        line=$(grep "$key.*=" $confile)
        [ -n "$line" ] && sed -i "/$key/d" $confile
        ori_val=$(echo $line | cut -d= -f2)
        if echo $ori_val | grep -q "'"; then
          new_value=$(echo $ori_val | sed "s/'/'${value}/")
        elif echo $ori_val | grep -q "\""; then
          new_value=$(echo $ori_val | sed "s/"/"${value}/")
        else
          new_vaue="${value}${ori_val}"
        fi
        echo "$key = $new_value" >> $confile
        hint_when_GUC_params_changed $key
        ;;
        *=*)
        echo "overwrite value"
        key=$(echo "$2" | cut -d= -f1)
        value=$(echo "$2" | cut -d= -f2)
        if grep -q $key $confile; then
          sed -i "/$key/d" $confile
        fi
        echo "$key = $value" >> $confile
        hint_when_GUC_params_changed $key
        ;;
        *)
        grep "$2" $confile
        ;;
      esac
      ;;
    reset)
    rm -fr $LTDATA
    rm -f $LTHOME/etc/ltcluster/ltcluster.pid
    ;;
    *)
    lt_ctl status
    ;;
  esac
}

manage_node() {
  for node in `find -maxdepth 1 -type d -name "node*" | sort`
  do
    echo -e "\033[1;32mEnter $node \033[0m"
    pushd $node >/dev/null
    source ./env.sh
    node $@
    echo -e "\033[1;31mExit $node\033[0m"
    popd >/dev/null
  done
}

case $1 in
  [0-9]*)
  node="node$1"
  pushd $node >/dev/null

  port=$(grep LTPORT env.sh | cut -d= -f2)
  echo "ON $node port $port"
  source ./env.sh

  case $2 in
    c|chat)
    ltsql
    ;;
    *)
    shift
    node $@
    ;;
  esac

  popd >/dev/null
  ;;
  *)
  manage_node $*
  ;;
esac
