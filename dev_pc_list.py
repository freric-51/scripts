#!/usr/bin/env python3
"""
    Programa que lista os pacotes dev do linux e salva em um sqlite
"""
import os
import stat
import sys
import pathlib
import subprocess
import sqlite3

# Constants
NODE_ME=os.uname().nodename
CMD_RET_DEV='apt list *-dev --installed'
DEV_INSTALL_FILE= pathlib.Path.home().joinpath('bin','dev_list.sh')

def create_db_connection(ref_file):
    """create or connect to sqlite file
    :param ref_file: file path and name
    :return conx: conection object"""
    conx=None
    try:
        conx = sqlite3.connect(ref_file)
        return conx
    except sqlite3.Error as error:
        print(error)
        return None
    # finally:
    #     if conn:
    #         conn.close()

def create_db_tables(connection):
    """ create table if not done yet
    :param ref_cur: cursor
    :return :"""
    sql_cmd = """ CREATE TABLE IF NOT EXISTS main.debian_packs (
                machine text NOT NULL,
                dev_pack_name text NOT NULL,
                PRIMARY KEY (machine, dev_pack_name)
                ); """
    ref_cur=connection.cursor()
    ref_cur.execute( sql_cmd )
    connection.commit()

def get_packs(cmd):
    """    executa o comando (cmd) e limpa o retorno que vem do shell    """
    (ret_status,ret_packs)=subprocess.getstatusoutput(cmd)
    if ret_status==1:
        id_error = 1
    elif ret_status>1:
        id_error = 1
    else: id_error = 0
    print(['\tExecution successful or with warnings when receiving packets',
        '\tFailed to get packages err='+str(ret_status)][id_error])

    list_durty= ret_packs.splitlines()
    list_clean=[]
    for data in list_durty:
        try:
            data=data.split()[0].lower()
            if data not in (['','warning:','listing...']):
                list_clean.append(data.split('/')[0])
        except Exception:
            pass
    return list_clean

def store_dev_packs(connection,machine,packs):
    """ store local dev packs
        :param connection: connection to sqlite file
        :param machine: machine name
        :param packs: list of dev packs
    """
    db_cursor=connection.cursor()
    for pack in packs:
        sql = 'insert or replace into main.debian_packs (machine, dev_pack_name) values ('
        sql = sql + "'" + machine + "','" + pack + "');"
        db_cursor.execute(sql)
    connection.commit()

def create_install_dev(file_name,dev_all):
    """ re-escrever (file) """
    # a=append w=write r=read / binary x text
    with open(file_name, 'w', encoding="ascii") as file_obj:
        file_obj.write('#!/usr/bin/env bash\n')
        file_obj.write('#automatic file created\n')
        file_obj.write('sudo apt install --assume-yes ') # first line needs a little push ;)
        file_obj.writelines('\nsudo apt install --assume-yes '.join(dev_all) )
        file_obj.close
        os.chmod (file_name,stat.S_IRWXU )

# DB File
file_db = pathlib.Path.home().joinpath('bin','dev_list.db')
conn=create_db_connection(file_db)
if not conn:
    sys.exit()

# creation of tabels
create_db_tables(conn)

# get dev packs
local_dev_packs=get_packs(CMD_RET_DEV)

# store local dev packs
store_dev_packs(conn,NODE_ME,local_dev_packs)

# cursor
cur = conn.cursor()
SQL_DIST ='SELECT distinct dev_pack_name FROM debian_packs '
SQL_DIST = SQL_DIST +' where dev_pack_name not in ( '
SQL_DIST = SQL_DIST + ' select dev_pack_name FROM debian_packs where machine = '
SQL_DIST = SQL_DIST + "'" + NODE_ME + "');"
cur.execute(SQL_DIST)
FIRST_ROW = True
list_cur=[]
for row in cur.fetchall():
    if FIRST_ROW:
        FIRST_ROW = False
        print('packags not in this machine:')
    list_cur.append(row[0])
    print(row[0])


if FIRST_ROW:
    FIRST_ROW = False
    print('All dev packs are installed here.')
else:
    create_install_dev(DEV_INSTALL_FILE,list_cur)

if conn:
    conn.close()
