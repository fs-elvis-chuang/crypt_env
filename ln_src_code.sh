echo "ln_src_code Shell=========>"
python --version
conda --version
pip --version
cat /etc/os-release

SITE_PACKAGES="/opt/miniconda/envs/$VIRTUAL_ENV_NAME/lib/python3.10/site-packages"
echo "套件安裝目錄＝ $SITE_PACKAGES"
echo "虛擬環境　　＝ $VIRTUAL_ENV_NAME"
echo "容器運行模式＝ $APP_MODE"


if [ "$APP_MODE" = "Dev" ]; then 
    echo "1.容器運行在 ${APP_MODE} 模式..."; 

elif [ "$APP_MODE" = "Pro" ]; then 
    echo "2.容器運行在 ${APP_MODE} 模式..."; 
    if [ -f /app_runnig ]; then
        echo "主程式已經運行中....................";
        cat /app_runnig
    else
        echo "準備程式碼--------------------------------------------------------Begin";
        # 刪除原始程式碼改用外掛
		echo "置換 vnpy"
		DIRECTORY_PATH="$SITE_PACKAGES/vnpy"
		if [ -d "$DIRECTORY_PATH" ]; then
			rm -rf "$SITE_PACKAGES/vnpy"
			ln -s "$SOURCE_CODE/vnpy_src/vnpy" "$SITE_PACKAGES" 
		else
			echo "目錄 $DIRECTORY_PATH 不存在。"
		fi
		
		echo "置換 vnpy_ctastrategy"
		DIRECTORY_PATH="$SITE_PACKAGES/vnpy_ctastrategy"
		if [ -d "$DIRECTORY_PATH" ]; then
			rm -rf "$SITE_PACKAGES/vnpy_ctastrategy"
			ln -s "$SOURCE_CODE/vnpy_src/vnpy_ctastrategy" "$SITE_PACKAGES" 
		else
			echo "目錄 $DIRECTORY_PATH 不存在。"
		fi
		
        echo "準備程式碼--------------------------------------------------------End";
        echo "程式碼啟動一次" >> /app_running;
        echo "APP_MODE=$APP_MODE" >> /app_running;
        echo "SITE_PACKAGES= $SITE_PACKAGES" >> /app_running;
        date >> /app_running;
        echo "============ 開始運行程式碼 ============"
        cd $SOURCE_CODE
        python main.py
        cd ~
        echo "============ 執行結束 ================="
        echo "程式碼啟動一次---End" >> /app_running;
        date >> /app_running;
    fi

    
elif [ "$APP_MODE" = "Tst" ]; then
	echo "3.容器運行在 ${APP_MODE} 模式...";
else
	echo "💢💢💢容器運行在 ${APP_MODE} 模式💢💢💢"; 
    echo "💢💢💢容器運行在 ${APP_MODE} 模式💢💢💢"; 
    echo "💢💢💢容器運行在 ${APP_MODE} 模式💢💢💢"; 
    echo "💢💢💢容器運行在 ${APP_MODE} 模式💢💢💢"; 
    echo "💢💢💢容器運行在 ${APP_MODE} 模式💢💢💢"; 
fi

