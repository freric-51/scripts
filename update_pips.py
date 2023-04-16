#!/usr/bin/env python3
"""
    Programa para update, instalação e sincronismo
    de pacotes python entre as máquinas do meu laboratório,
    no porão da minha casa.
"""
# packs installed in  ./.local/lib/python3.8/
import os
import subprocess
# from subprocess import run, getstatusoutput
import time
import datetime
# import shlex
# import hashlib
import pathlib #import Path

file_transfer= pathlib.Path.home().joinpath('bin','pip_list.lst')
file_not_pip = pathlib.Path.home().joinpath('bin','pip_not.lst')

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
    return remove_invalid_packname(ret_packs.splitlines())

def remove_invalid_packname(packs):
    """ exclude from list invalid pack name """
    attention_list=['WARNING:',
        'Package',
        '---',
        '\n']
    ret_list = []
    for linha in packs:
        try:
            linha = linha.split()[0].strip()    # get 1st collumn
        except:
            linha=linha.strip()

        linha = linha.rstrip()
        if not any(pack in linha for pack in attention_list):
            if linha != '':
                linha = linha.lower()
                ret_list.append(linha) # if linha not in attention_list
    return ret_list

def passo_01():
    """ ler lista de packs instalados [instalados] """
    return get_packs('pip list')

def passo_02():
    """ ler lista de packs desatualizados [outdated] """
    return get_packs('pip list --outdated')

def passo_03(file_name):
    """ se existir, ler lista de packs de outros computadores (file_transfer)\n
        onde pode-se manualmente adicionar os packs para a primeira instalação.
    """
    ret_list = []
    if os.path.exists(file_name):
        file_obj = open(file_name, "r", encoding="utf-8") # a=append w=write r=read
        for line in file_obj:
            line=line.replace('\n','')
            ret_list.append(line)
        file_obj.close
    return remove_invalid_packname(ret_list)

def passo_04(p_inst,p_pcs):
    """ Unir as lista [tudo] = [instalados] + [computadores] removendo os duplicados. """
    data_set=set(p_inst+p_pcs)
    data_list=list(data_set)
    data_list.sort(key=str.lower)
    return data_list

def passo_05(p_inst,p_all,p_outd):
    """ Criar lista com os [nao_instalados] e [outdated] """
    dif_list = list(set(p_all) - set(p_inst))
    new_list = list(set(dif_list + p_outd))
    new_list.sort(key=str.lower)
    return new_list

def passo_06(file_name,p_all):
    """ re-escrever (file_transfer) """
    # a=append w=write r=read / binary x text
    with open(file_name, 'w', encoding="utf-8") as file_obj:
        file_obj.writelines('\n'.join(p_all) )
        file_obj.close

def passo_07(p_new):
    """ rodar instalação ou upgrade com a lista [desatualizados] + [nao_instalados] """
    p_not_approved = []
    p_need_debian  = []
    cmd_base = 'pip install --user --upgrade '
    for pack in p_new:
        cmd_full = cmd_base + pack
        (ret_status,ret_results)=subprocess.getstatusoutput(cmd_full)
        if ret_status>0:
            lst_results=ret_results.split(sep='\n')
            err_base='WARNING: Retrying'
            if [list_element_w for list_element_w in lst_results if err_base in list_element_w]:
                print('\tNetwork error during packet processing ' + pack)
                ret_status=0
            else:
                err_base='ERROR: No matching distribution found for'
                if [list_element_e for list_element_e in lst_results if err_base in list_element_e]:
                    print('\tPack not in PIP ' + pack )
                    p_not_approved.append(pack)
                    ret_status=0

                for list_element_r in lst_results:
                    err_base='Please install the'
                    if err_base in list_element_r:
                        msg_part=(pack + '. ' + list_element_r.strip()).replace('  ',' ')
                        print('\tInstall linux package before: ' + msg_part)
                        p_need_debian.append(msg_part)
                        ret_status=0

                    err_base='not found'
                    if err_base in list_element_r:
                        msg_part=(pack + '. ' + list_element_r.strip()).replace('  ',' ')
                        print('\tInstall linux package before: ' + msg_part)
                        p_need_debian.append(msg_part)
                        ret_status=0
            if ret_status>0:
                print( 'unknow error: ' + str(ret_results.split()[1] ))

        else:
            print('\tExecution successful or with warnings installing/upgrading ' + pack)
            # id_print = 0
            # print([    '    Execution successful or with warnings',
            #         '    Failed execution err='+str(ret_status)][id_print])
    return p_not_approved, p_need_debian

def remove_pip_pack(p_installed,p_not_accepted):
    """uninstall pips that will not be used anymore."""
    p_to_uninstall=list(set(p_installed)&set(p_not_accepted))
    for list_element_u in p_to_uninstall:
        cmd='pip uninstall ' + list_element_u  + ' -y'
        (ret_status,ret_packs)=subprocess.getstatusoutput(cmd)
        if ret_status == 0:
            print('\n')
            for line in ret_packs.splitlines():
                print(str(line).strip())
                # print('\n' + str(ret_packs.splitlines()).strip())

# -----------------------------------------------------------------
print('Freitas 2023/04/03 11h11')

pack_installed = passo_01()
print('\tReturned : ' + str(len(pack_installed)) + ' instaled\n')

pack_outdated  = passo_02()
print('\tReturned : ' + str(len(pack_outdated)) + ' outdated\n')

pack_others_pcs = passo_03(file_transfer)
pack_not_from_pcs = passo_03(file_not_pip)
print('\tReturned : ' + str(len(pack_not_from_pcs)) + ' not pip packs from others PCs\n')

pack_all        = passo_04(pack_installed, pack_others_pcs)
pack_new        = passo_05(pack_installed, pack_all, pack_outdated)

print('\tExecutar upgrade/instalação de ' + str(len(pack_new)) + ' pacotes.' + str(pack_new))
pack_not_here,pack_debian = passo_07(pack_new)

pack_not_all= list(set(pack_not_here + pack_not_from_pcs))
pack_not_all.sort(key=str.lower)
passo_06(file_not_pip,pack_not_all)
if len(pack_not_all)>0:
    MSG_PART_I=''
    for list_element_i in pack_not_all:
        MSG_PART_I=MSG_PART_I+'\n\t' +list_element_i
    print('\nPacks inexistente na ou a remover da base PIP ou pack Debian ' + MSG_PART_I)

remove_pip_pack(pack_installed,pack_not_from_pcs)

pack_all_clean = list(set(pack_all) - set(pack_not_all))
pack_all_clean.sort(key=str.lower)
passo_06(file_transfer,pack_all_clean)

if len(pack_debian)>0:
    MSG_PART_P=''
    for list_element_p in pack_debian:
        MSG_PART_P=MSG_PART_P+'\n\t'+list_element_p
    print('\nPacks necessitam (ou não) de pacotes linux ' + MSG_PART_P)

my_time=datetime.datetime.now()
end_time=str(my_time.hour).zfill(2) + \
      ':' + str(my_time.minute).zfill(2) + \
      ':' + str(my_time.second).zfill(2)
print('Fim @ ' + end_time)
time.sleep(10)

# cmd_01 = 'pip list --outdated'
# (ret_status,ret_packs)=getstatusoutput(cmd_01)
# if ret_status>0: id_print = 1
# else: id_print = 0
# print(['    Execution successful or with warnings when receiving packets',
#        '    Failed to get packages err='+str(ret_status)][id_print])
# ret_packs=ret_packs.splitlines()

# cmd_02 = 'pip install --user --upgrade '
# attention_list=['WARNING:',
#         'Package',
#         '--------------------',
#         '-------------------',
#         '------------------',
#         '-----------------',
#         '----------------',
#         '---------------',
#         '--------------',
#         '-------------',
#         '------------',
#         '-----------',
#         '---------',
#         '--------',
#         '-------',
#         '------',
#         '-----',
#         '----',
#         '---']
# for linha in ret_packs:
#     linha = linha.split()[0].strip()
#     if linha not in attention_list:
#         # cmd_03 = (cmd_02 + linha).split()
#         cmd_03 = shlex.split(cmd_02 + linha)
#         print('\n', cmd_02, linha)
#         ret_status=subprocess.run(args=cmd_03).returncode
#         if ret_status>0: id_print = 1
#         else: id_print = 0
#         print([    '    Execution successful or with warnings',
#                  '    Failed execution err='+str(ret_status)][id_print])

# print('Fim.')
# time.sleep(10)

# # pip list --outdated ///for test prupouses --uptodate
# # os.system('pip install  --user --upgrade xxxx')
# # cmd_01 = "pip list --uptodate | awk '{ print $1 }' | awk 'NR>2' "

# # [2:] remove the header = 2 lines
# # Package              Version
# # -------------------- -----------
# # ret_packs=ret_packs.splitlines()[2:]
