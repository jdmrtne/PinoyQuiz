// Hand-written to match supabase/migrations/*.sql (Phase 2).
// Once the project is linked, regenerate the authoritative version with:
//   npx supabase gen types typescript --project-id <ref> > src/types/database.types.ts
// and diff it against this file before overwriting.

export type GameStatusRow =
  | "WAITING"
  | "COUNTDOWN"
  | "QUESTION"
  | "REVEAL"
  | "LEADERBOARD"
  | "FINISHED";

export type GameCategorySetting =
  | "history"
  | "geography"
  | "culture"
  | "food"
  | "entertainment"
  | "sports"
  | "trivia"
  | "slang"
  | "random";

export type QuestionCategoryRow = Exclude<GameCategorySetting, "random">;
export type QuestionDifficultyRow = "easy" | "medium" | "hard";
export type GameDifficultySetting = QuestionDifficultyRow | "mixed";
export type AnswerOptionRow = "A" | "B" | "C" | "D";

export interface Database {
  public: {
    Tables: {
      games: {
        Row: {
          id: string;
          room_code: string;
          host_user_id: string;
          status: GameStatusRow;
          category: GameCategorySetting;
          difficulty: GameDifficultySetting;
          question_count: number;
          time_limit_seconds: number;
          scoring_config: {
            basePoints: number;
            maxSpeedBonus: number;
            incorrectPoints: number;
            noAnswerPoints: number;
          };
          current_question_index: number;
          current_question_id: string | null;
          question_started_at: string | null;
          created_at: string;
          started_at: string | null;
          finished_at: string | null;
        };
        Insert: Partial<Database["public"]["Tables"]["games"]["Row"]>;
        Update: Partial<Database["public"]["Tables"]["games"]["Row"]>;
        Relationships: [];
      };
      players: {
        Row: {
          id: string;
          game_id: string;
          user_id: string;
          nickname: string;
          score: number;
          is_host: boolean;
          connected: boolean;
          joined_at: string;
          last_seen_at: string;
        };
        Insert: Partial<Database["public"]["Tables"]["players"]["Row"]>;
        Update: Partial<Database["public"]["Tables"]["players"]["Row"]>;
        Relationships: [];
      };
      // questions and game_questions are intentionally NOT queryable directly
      // from the client (no grant — see supabase/migrations/0006_grants.sql).
      // They're typed here only so server-side (function) code has a shape
      // to reference; the frontend should never import these Row types for
      // a direct `.from("questions")` call.
      questions: {
        Row: {
          id: string;
          category: QuestionCategoryRow;
          difficulty: QuestionDifficultyRow;
          prompt: string;
          option_a: string;
          option_b: string;
          option_c: string;
          option_d: string;
          correct_option: AnswerOptionRow;
          explanation: string | null;
          created_at: string;
        };
        Insert: Partial<Database["public"]["Tables"]["questions"]["Row"]>;
        Update: Partial<Database["public"]["Tables"]["questions"]["Row"]>;
        Relationships: [];
      };
      game_questions: {
        Row: {
          id: string;
          game_id: string;
          question_id: string;
          question_order: number;
          shuffle_map: number[];
        };
        Insert: Partial<Database["public"]["Tables"]["game_questions"]["Row"]>;
        Update: Partial<Database["public"]["Tables"]["game_questions"]["Row"]>;
        Relationships: [];
      };
      answers: {
        Row: {
          id: string;
          game_id: string;
          player_id: string;
          question_id: string;
          selected_option: number | null;
          is_correct: boolean;
          response_time_ms: number | null;
          points: number;
          created_at: string;
        };
        Insert: Partial<Database["public"]["Tables"]["answers"]["Row"]>;
        Update: Partial<Database["public"]["Tables"]["answers"]["Row"]>;
        Relationships: [];
      };
    };
    Views: {
      questions_public: {
        Row: {
          id: string;
          category: QuestionCategoryRow;
          difficulty: QuestionDifficultyRow;
          prompt: string;
          option_a: string;
          option_b: string;
          option_c: string;
          option_d: string;
        };
        Relationships: [];
      };
      leaderboard: {
        Row: {
          player_id: string;
          game_id: string;
          nickname: string;
          score: number;
          is_host: boolean;
          connected: boolean;
          rank: number;
        };
        Relationships: [];
      };
    };
    Functions: {
      create_game: {
        Args: {
          p_category?: GameCategorySetting;
          p_difficulty?: GameDifficultySetting;
          p_question_count?: number;
          p_time_limit_seconds?: number;
          p_host_nickname?: string;
        };
        Returns: {
          out_game_id: string;
          out_room_code: string;
          out_player_id: string;
        }[];
      };
      lookup_game_by_room_code: {
        Args: { p_room_code: string };
        Returns: {
          found: boolean;
          status: GameStatusRow | null;
          category: GameCategorySetting | null;
          difficulty: GameDifficultySetting | null;
          question_count: number | null;
          time_limit_seconds: number | null;
        }[];
      };
      join_game: {
        Args: { p_room_code: string; p_nickname: string };
        Returns: {
          out_game_id: string;
          out_player_id: string;
          out_status: GameStatusRow;
          out_is_host: boolean;
          out_reconnected: boolean;
        }[];
      };
      remove_player: {
        Args: { p_player_id: string };
        Returns: undefined;
      };
      start_game: {
        Args: { p_game_id: string };
        Returns: undefined;
      };
      begin_first_question: {
        Args: { p_game_id: string };
        Returns: undefined;
      };
      get_current_question: {
        Args: { p_game_id: string };
        Returns: {
          out_question_id: string;
          out_prompt: string;
          out_option_1: string;
          out_option_2: string;
          out_option_3: string;
          out_option_4: string;
          out_order: number;
          out_total: number;
          out_time_limit_seconds: number;
          out_question_started_at: string;
        }[];
      };
      submit_answer: {
        Args: { p_game_id: string; p_selected_option: number };
        Returns: {
          out_is_correct: boolean;
          out_points: number;
        }[];
      };
      end_question: {
        Args: { p_game_id: string };
        Returns: undefined;
      };
      get_answer_reveal: {
        Args: { p_game_id: string };
        Returns: {
          out_question_id: string;
          out_correct_option: number;
          out_correct_text: string;
          out_explanation: string | null;
          out_your_answer: number | null;
          out_your_points: number;
          out_was_correct: boolean;
          out_percent_correct: number;
        }[];
      };
      advance_to_leaderboard: {
        Args: { p_game_id: string };
        Returns: undefined;
      };
      get_leaderboard: {
        Args: { p_game_id: string };
        Returns: {
          out_player_id: string;
          out_nickname: string;
          out_score: number;
          out_rank: number;
          out_score_delta: number;
        }[];
      };
      advance_question: {
        Args: { p_game_id: string };
        Returns: undefined;
      };
      heartbeat: {
        Args: { p_game_id: string };
        Returns: undefined;
      };
      mark_stale_players: {
        Args: { p_game_id: string };
        Returns: undefined;
      };
      claim_host: {
        Args: { p_game_id: string };
        Returns: {
          out_new_host_player_id: string;
          out_new_host_nickname: string;
        }[];
      };
    };
    Enums: {
      game_status: GameStatusRow;
      game_category_setting: GameCategorySetting;
      question_category: QuestionCategoryRow;
      question_difficulty: QuestionDifficultyRow;
      game_difficulty_setting: GameDifficultySetting;
      answer_option: AnswerOptionRow;
    };
  };
}
