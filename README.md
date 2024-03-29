# Database Toolbox

## node.sh

### When to use it?

manage multiple lightdb instance in one machine. Each instance has a distinct port.

### How to use it?

  - create a root directory `cloud/{node01,node02,node03}` ..., 
  - copy lightdb package into `node01`, `node02`, `node03`, ...
  - create a `env.sh` file inside each `nodeN` directory
  - place `node.sh` in `cloud` directory
  - `node.sh add 01`
  - `node.sh start`, `node.sh stop`, `node.sh reload`, `node.sh config wal_level`
  - `node.sh config wal_level=logical`, `node.sh config shared_preload_libraries+='canopy,'`
  - `node.sh 01 status`, `node.sh 01 stop`, ...

See Chinese [article](https://www.cnblogs.com/lddcool/p/lightdb_node_script.html) for detail.


## sqltest

sql query executed on postgresql

```shell
./sqltest oracle_null_test.sql
```


## squery

sql query executed on oracle

```shell
./squery oracle_replace_test.sql.d
./sqltest oracle_replace_test.sql
```
