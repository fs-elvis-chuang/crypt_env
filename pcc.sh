echo "目前執行 pcc Shell=========>"
python --version
conda --version
pip --version
echo "預先定義環境變數============================================>"
echo "環境變數localWorkspaceFolder             ==> ${localWorkspaceFolder}"
echo "環境變數localWorkspaceFolderBasename     ==> ${localWorkspaceFolderBasename}"
echo "環境變數containerWorkspaceFolder         ==> ${containerWorkspaceFolder}"
echo "環境變數containerWorkspaceFolderBasename ==> ${containerWorkspaceFolderBasename}"
echo "環境變數devcontainerId                   ==> ${devcontainerId}"
echo "環境變數LOCAL_USER_PATH                  ==> ${LOCAL_USER_PATH}"
echo "環境變數My_Local_Env                     ==> ${My_Local_Env}"
echo "環境變數My_Path                          ==> ${My_Path}"
echo "環境變數VIRTUAL_ENV_NAME                 ==> ${VIRTUAL_ENV_NAME}"
echo "作業系統環境變數============================================>"
lsb_release -a
env

# conda activate my_en


# cd $SITE_PACKAGES
# pwd
# ls -al "$SITE_PACKAGES/vnpy"
# cd "$SITE_PACKAGES/vnpy"
# ls -al
# DIRECTORY_PATH="$SITE_PACKAGES/vnpy"
# if [ -d "$DIRECTORY_PATH" ]; then
#   ls -al "$DIRECTORY_PATH"
#   echo "目錄 $DIRECTORY_PATH 存在。"
# else
#   echo "目錄 $DIRECTORY_PATH 不存在。"
# fi



# if [-d "$SITE_PACKAGES/vnpy"]; then
#     ls -al "$SITE_PACKAGES/vnpy"
#     # rm -rf "$SITE_PACKAGES/vnpy"
#     # ln -s "$CURRENT_DIR/vnpy_src/vnpy" "$SITE_PACKAGES" 
# else
#     echo "$SITE_PACKAGES/vnpy 目錄不存在。"
# fi

# if [[-d "$SITE_PACKAGES/vnpy_ctastrategy"]]; then
#     ls "$SITE_PACKAGES/vnpy_ctastrategy"
#     # rm -rf "$SITE_PACKAGES/vnpy_ctastrategy"
#     # ln -s "$CURRENT_DIR/vnpy_src/vnpy_ctastrategy" "$SITE_PACKAGES"
# else
#     echo "$SITE_PACKAGES/vnpy_ctastrategy  目錄不存在"
#     ls "$SITE_PACKAGES/vnpy_ctastrategy"
# fi
# python main.py
if [ "$APP_MODE" = "Dev" ]; then
    echo "開發環境中安裝套件============================================>";
    PYTHON_PAK="numpy==2.2.6";
    echo "安裝套件：${PYTHON_PAK}..."
    pip install $PYTHON_PAK
    
    echo "置換套件原始碼============================================>";
    # 儲存當前目錄路徑
    CURRENT_DIR=$(pwd)
    echo $CURRENT_DIR

    SITE_PACKAGES="/opt/miniconda/envs/$VIRTUAL_ENV_NAME/lib/python3.10/site-packages"
    echo "套件安裝目錄= $SITE_PACKAGES"
    ls -al $SITE_PACKAGES

    echo "置換 vnpy"
    DIRECTORY_PATH="$SITE_PACKAGES/vnpy"
    if [ -d "$DIRECTORY_PATH" ]; then
      rm -rf "$SITE_PACKAGES/vnpy"
      ln -s "$CURRENT_DIR/vnpy_src/vnpy" "$SITE_PACKAGES" 
    else
      echo "目錄 $DIRECTORY_PATH 不存在。"
    fi

    echo "置換 vnpy_ctastrategy"
    DIRECTORY_PATH="$SITE_PACKAGES/vnpy_ctastrategy"
    if [ -d "$DIRECTORY_PATH" ]; then
      rm -rf "$SITE_PACKAGES/vnpy_ctastrategy"
      ln -s "$CURRENT_DIR/vnpy_src/vnpy_ctastrategy" "$SITE_PACKAGES" 
    else
      echo "目錄 $DIRECTORY_PATH 不存在。"
    fi
    
else
    echo "目前處在APP_MODE= $APP_MODE ...";
    echo "目前處在APP_MODE= $APP_MODE ...";
    echo "目前處在APP_MODE= $APP_MODE ...";
fi