#!/usr/bin/env python3
"""
清理文件中的 null 字节

使用方法：
python clean_nullbytes.py <文件路径>
"""

import sys
import os

def clean_null_bytes(file_path):
    """从文件中移除所有 null 字节"""
    if not os.path.exists(file_path):
        print(f"错误: 文件不存在 - {file_path}")
        return False
    
    try:
        # 读取文件内容
        with open(file_path, 'rb') as file:
            content = file.read()
        
        # 检查是否包含 null 字节
        if b'\x00' not in content:
            print(f"文件中没有找到 null 字节 - {file_path}")
            return True
        
        # 移除 null 字节
        clean_content = content.replace(b'\x00', b'')
        
        # 备份原文件
        backup_path = file_path + '.bak'
        with open(backup_path, 'wb') as backup_file:
            backup_file.write(content)
        print(f"原始文件已备份到 - {backup_path}")
        
        # 写回清理后的内容
        with open(file_path, 'wb') as file:
            file.write(clean_content)
        
        print(f"成功: 已从文件中删除 null 字节 - {file_path}")
        return True
    
    except Exception as e:
        print(f"错误: 处理文件时出错 - {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("用法: python clean_nullbytes.py <文件路径>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    success = clean_null_bytes(file_path)
    sys.exit(0 if success else 1)
