-- ============================================================
--  My Digital Sketchbook — Supabase Schema
--  新しいSupabaseプロジェクトで、SQL Editorにそのままペーストして実行
-- ============================================================

-- 1. posts テーブル
CREATE TABLE IF NOT EXISTS public.posts (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title      text          NOT NULL DEFAULT '',
  content    text          NOT NULL DEFAULT '',
  image_url  text          NOT NULL DEFAULT '',
  post_date  date          NOT NULL,
  tags       text[]        NOT NULL DEFAULT '{}',
  created_at timestamptz   NOT NULL DEFAULT now()
);

-- 2. Row Level Security (RLS) を有効化
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- 3. RLSポリシー: 誰でも読める（Gallery/Diary表示用）
CREATE POLICY "Anyone can read posts"
  ON public.posts
  FOR SELECT
  USING (true);

-- 4. RLSポリシー: 誰でも書ける（認証なしで投稿・編集できる現構成に合わせる）
--    ※ 本番で認証を追加する場合はこのポリシーを削除し auth.uid() を使うこと
CREATE POLICY "Anyone can insert posts"
  ON public.posts
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update posts"
  ON public.posts
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ============================================================
--  Storage バケット設定
--  ※ SQLでは作成できないため、下記を参考にダッシュボードで手動作成
-- ============================================================
--
--  Storage > New bucket
--    Name      : images
--    Public    : ✅ ON（Public bucketにチェック）
--
--  Storage > Policies > images バケット
--    - SELECT (読み取り): 全員許可
--    - INSERT (アップロード): 全員許可
--
--  もしくは以下のSQLでポリシーだけ設定（バケット自体はダッシュボードで作成後に実行）:
-- ============================================================

-- Storage RLSポリシー（バケット作成後に実行）
-- INSERT INTO storage.buckets (id, name, public) VALUES ('images', 'images', true);
-- ↑ Supabase管理バケットはSQLで直接insertできないためコメントアウト。ダッシュボードで作成。

CREATE POLICY "Public read images"
  ON storage.objects FOR SELECT
  USING ( bucket_id = 'images' );

CREATE POLICY "Public upload images"
  ON storage.objects FOR INSERT
  WITH CHECK ( bucket_id = 'images' );
