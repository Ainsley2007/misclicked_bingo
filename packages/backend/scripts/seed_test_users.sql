-- Seed script for test users
-- Run this with: sqlite3 bingo-globe.db < seed_test_users.sql

-- Clear existing test data (optional - comment out if you want to keep existing data)
DELETE FROM team_members;
DELETE FROM teams;
DELETE FROM users WHERE discord_id LIKE 'test_%';

-- Insert test users
INSERT INTO users (id, discord_id, global_name, username, email, avatar, role, team_id, game_id) VALUES
  -- Admin user
  ('admin-user-id-1', 'test_admin_001', 'Admin User', 'admin_test', 'admin@test.com', NULL, 'admin', NULL, NULL),
  
  -- Regular users (no team)
  ('user-id-2', 'test_user_002', 'Alice Anderson', 'alice_test', 'alice@test.com', NULL, 'user', NULL, NULL),
  ('user-id-3', 'test_user_003', 'Bob Builder', 'bob_test', 'bob@test.com', NULL, 'user', NULL, NULL),
  ('user-id-4', 'test_user_004', 'Charlie Chen', 'charlie_test', 'charlie@test.com', NULL, 'user', NULL, NULL),
  ('user-id-5', 'test_user_005', 'Diana Davis', 'diana_test', 'diana@test.com', NULL, 'user', NULL, NULL),
  ('user-id-6', 'test_user_006', 'Eve Evans', 'eve_test', 'eve@test.com', NULL, 'user', NULL, NULL),
  ('user-id-7', 'test_user_007', 'Frank Foster', 'frank_test', 'frank@test.com', NULL, 'user', NULL, NULL),
  ('user-id-8', 'test_user_008', 'Grace Green', 'grace_test', 'grace@test.com', NULL, 'user', NULL, NULL),
  ('user-id-9', 'test_user_009', 'Henry Hill', 'henry_test', 'henry@test.com', NULL, 'user', NULL, NULL),
  ('user-id-10', 'test_user_010', 'Iris Ivanov', 'iris_test', 'iris@test.com', NULL, 'user', NULL, NULL);

-- Display the inserted users
SELECT 
  global_name, 
  username, 
  role,
  CASE 
    WHEN team_id IS NOT NULL THEN 'In Team'
    ELSE 'No Team'
  END as team_status
FROM users 
WHERE discord_id LIKE 'test_%'
ORDER BY role DESC, global_name;

