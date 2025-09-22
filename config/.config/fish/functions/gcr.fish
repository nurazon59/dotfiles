function gcr
    set repo_name $argv[1]
    set -e argv[1]
    
    if test -z "$repo_name"
        echo "使い方: gcr <repository-name> [gh repo create options]"
        return 1
    end
    
    # GitHubユーザー名を取得
    set github_user (gh api user --jq .login)
    
    # ghqのパスを作成
    set repo_path (ghq root)"/github.com/$github_user/$repo_name"
    
    # GitHubにリポジトリ作成（デフォルトでプライベート、READMEとMITライセンス追加）
    gh repo create "$repo_name" --private --add-readme --license mit $argv
    
    # ghqでクローン
    ghq get "$github_user/$repo_name"
    
    # 作成したディレクトリに移動
    cd "$repo_path"
end