<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>自定义文件上传</title>
    <style>
        .upload-box { padding: 30px; max-width: 500px; margin: 50px auto; border: 1px dashed #ccc; border-radius: 8px; text-align: center; }
        #fileInput { margin: 20px 0; padding: 10px; }
        #uploadBtn { padding: 10px 30px; background: #2ea44f; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
        #tip { margin-top: 20px; color: #666; }
    </style>
</head>
<body>
    <div class="upload-box">
        <h2>文件上传至仓库</h2>
        <input type="file" id="fileInput" multiple>
        <button id="uploadBtn">开始上传</button>
        <div id="tip"></div>
    </div>

    <script>
        // 配置信息（需替换为你的仓库信息和Token）
        const config = {
            owner: "fox925", // 你的GitHub用户名
            repo: "fox", // 仓库名
            branch: "main", // 目标分支
            token: "你的GitHub个人访问令牌", // 需开启repo权限
            folder: "" // 上传到仓库根目录，需子目录填路径（如"docs/"）
        };

        // 上传逻辑
        document.getElementById("uploadBtn").addEventListener("click", async () => {
            const fileInput = document.getElementById("fileInput");
            const tip = document.getElementById("tip");
            if (!fileInput.files.length) {
                tip.style.color = "#dc3545";
                tip.textContent = "请选择要上传的文件！";
                return;
            }

            tip.textContent = "上传中...";
            const file = fileInput.files[0];
            const reader = new FileReader();

            reader.onload = async (e) => {
                const base64Str = e.target.result.split(",")[1]; // 提取base64内容
                const fileName = file.name;
                const fileUrl = `https://api.github.com/repos/${config.owner}/${config.repo}/contents/${config.folder}${fileName}`;

                try {
                    // 先查询文件是否存在（存在则获取sha值用于更新）
                    const res = await fetch(fileUrl, {
                        headers: { Authorization: `token ${config.token}` }
                    });
                    
                    const data = await res.json();
                    const requestData = {
                        message: `上传文件：${fileName}`,
                        content: base64Str,
                        branch: config.branch
                    };
                    if (data.sha) requestData.sha = data.sha; // 存在则加sha值

                    // 提交上传/更新请求
                    const uploadRes = await fetch(fileUrl, {
                        method: res.ok ? "PUT" : "POST",
                        headers: {
                            Authorization: `token ${config.token}`,
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify(requestData)
                    });

                    if (uploadRes.ok) {
                        tip.style.color = "#28a745";
                        tip.textContent = `文件${fileName}上传成功！`;
                    } else {
                        tip.style.color = "#dc3545";
                        tip.textContent = "上传失败，检查配置信息！";
                    }
                } catch (err) {
                    tip.style.color = "#dc3545";
                    tip.textContent = "上传出错：" + err.message;
                }
            };

            reader.readAsDataURL(file);
        });
    </script>
</body>
</html>
