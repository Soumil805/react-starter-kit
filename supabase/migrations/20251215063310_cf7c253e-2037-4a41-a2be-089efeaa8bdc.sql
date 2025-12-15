-- Create enums first
CREATE TYPE public.app_role AS ENUM ('player', 'organizer', 'admin', 'umpire', 'ground_owner');
CREATE TYPE public.batting_style AS ENUM ('right_handed', 'left_handed');
CREATE TYPE public.bowling_style AS ENUM ('right_arm_fast', 'left_arm_fast', 'right_arm_medium', 'left_arm_medium', 'right_arm_spin', 'left_arm_spin', 'none');
CREATE TYPE public.gender AS ENUM ('male', 'female', 'other');
CREATE TYPE public.player_category AS ENUM ('a_plus', 'a', 'b', 'c');
CREATE TYPE public.player_type AS ENUM ('batsman', 'bowler', 'all_rounder', 'wicket_keeper');
CREATE TYPE public.tournament_type AS ENUM ('Normal', 'Auction', 'Auction with Voting');

-- Create profiles table
CREATE TABLE public.profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL UNIQUE,
  full_name text,
  avatar_url text,
  mobile text,
  date_of_birth date,
  gender public.gender,
  address text,
  city text,
  state text,
  pincode text,
  bio text,
  player_type public.player_type,
  batting_style public.batting_style,
  bowling_style public.bowling_style,
  player_category public.player_category,
  is_player_registered boolean DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create user_roles table
CREATE TABLE public.user_roles (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL,
  role public.app_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, role)
);

-- Create grounds table with country and is_active
CREATE TABLE public.grounds (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  country text NOT NULL DEFAULT 'India',
  state text NOT NULL,
  city text NOT NULL,
  address text,
  pincode text,
  is_active boolean NOT NULL DEFAULT true,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create tournaments table with tournament_type
CREATE TABLE public.tournaments (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  organizer_id uuid NOT NULL,
  name text NOT NULL,
  slogan text,
  description text,
  logo_url text,
  tournament_type public.tournament_type NOT NULL DEFAULT 'Normal',
  category text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  ball_type text NOT NULL,
  pitch_type text NOT NULL,
  match_type text NOT NULL,
  overs integer NOT NULL,
  number_of_teams integer NOT NULL,
  players_per_team integer NOT NULL,
  team_budget integer NOT NULL DEFAULT 1000000,
  base_price integer NOT NULL DEFAULT 10000,
  captain_voting_enabled boolean DEFAULT false,
  max_votes_per_player integer,
  ground_id uuid REFERENCES public.grounds(id),
  venue_name text,
  venue_state text,
  venue_city text,
  venue_address text,
  venue_pincode text,
  entry_fee integer DEFAULT 0,
  payment_instructions text,
  payment_qr_url text,
  organizer_name text,
  organizer_mobile text,
  is_active boolean DEFAULT true,
  is_voting_live boolean DEFAULT false,
  is_auction_live boolean DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create teams table
CREATE TABLE public.teams (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tournament_id uuid NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  name text NOT NULL,
  logo_url text,
  owner_id uuid,
  captain_id uuid,
  budget_remaining integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create team_players table
CREATE TABLE public.team_players (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id uuid NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
  player_id uuid NOT NULL,
  sold_price integer NOT NULL,
  is_captain boolean DEFAULT false,
  sold_at timestamptz NOT NULL DEFAULT now()
);

-- Create tournament_applications table
CREATE TABLE public.tournament_applications (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tournament_id uuid NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  player_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  payment_proof_url text,
  reviewed_at timestamptz,
  applied_at timestamptz NOT NULL DEFAULT now()
);

-- Create auction_bids table
CREATE TABLE public.auction_bids (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  tournament_id uuid NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
  team_id uuid NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
  player_id uuid NOT NULL,
  bid_amount integer NOT NULL,
  bid_at timestamptz NOT NULL DEFAULT now()
);

-- Create has_role function
CREATE OR REPLACE FUNCTION public.has_role(_role public.app_role, _user_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = _user_id AND role = _role
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auction_bids ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Public profiles are viewable" ON public.profiles FOR SELECT USING (true);

-- User roles policies
CREATE POLICY "Users can view their own roles" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own roles" ON public.user_roles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Grounds policies (public read, owner/admin write)
CREATE POLICY "Anyone can view active grounds" ON public.grounds FOR SELECT USING (is_active = true);
CREATE POLICY "Ground owners can manage their grounds" ON public.grounds FOR ALL USING (auth.uid() = created_by);

-- Tournaments policies
CREATE POLICY "Anyone can view active tournaments" ON public.tournaments FOR SELECT USING (is_active = true);
CREATE POLICY "Organizers can create tournaments" ON public.tournaments FOR INSERT WITH CHECK (auth.uid() = organizer_id);
CREATE POLICY "Organizers can update their tournaments" ON public.tournaments FOR UPDATE USING (auth.uid() = organizer_id);
CREATE POLICY "Organizers can delete their tournaments" ON public.tournaments FOR DELETE USING (auth.uid() = organizer_id);

-- Teams policies
CREATE POLICY "Anyone can view teams" ON public.teams FOR SELECT USING (true);
CREATE POLICY "Tournament organizers can manage teams" ON public.teams FOR ALL USING (
  EXISTS (SELECT 1 FROM public.tournaments WHERE id = tournament_id AND organizer_id = auth.uid())
);

-- Team players policies
CREATE POLICY "Anyone can view team players" ON public.team_players FOR SELECT USING (true);

-- Tournament applications policies
CREATE POLICY "Players can view their own applications" ON public.tournament_applications FOR SELECT USING (auth.uid() = player_id);
CREATE POLICY "Organizers can view applications for their tournaments" ON public.tournament_applications FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.tournaments WHERE id = tournament_id AND organizer_id = auth.uid())
);
CREATE POLICY "Players can apply to tournaments" ON public.tournament_applications FOR INSERT WITH CHECK (auth.uid() = player_id);

-- Auction bids policies
CREATE POLICY "Anyone can view bids" ON public.auction_bids FOR SELECT USING (true);