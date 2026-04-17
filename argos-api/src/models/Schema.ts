export type TaskStatus = 'open' | 'in_progress' | 'review' | 'closed';
export type ObservationStatus = 'detected' | 'promoted' | 'discarded';

export interface Task {
  id: string;
  title: string;
  status: TaskStatus;
  owner: string; 
  project: string;
  dependencies: string[]; // IDs of other tasks
  linked_artifacts: string[]; // Google Drive file IDs
  created_at: Date;
  updated_at: Date;
}

export interface Event {
  id: string;
  timestamp: Date;
  agent: string; // The AI or human triggering the event
  task_id: string;
  event_type: 'action' | 'note' | 'error' | 'status_change';
  summary: string;
  payload: any; // Additional payload
  verification?: string;
}

export interface Artifact {
  drive_file_id: string;
  kind: 'document' | 'spreadsheet' | 'markdown' | 'pdf' | 'script';
  title: string;
  project: string;
  canonical: boolean;
  linked_task?: string;
  mime_type: string;
  path_hint: string;
}

export interface Rule {
  id: string;
  statement: string;
  scope: 'global' | 'project';
  evidence: string;
  confidence: 'high' | 'absolute';
  status: 'draft' | 'active' | 'deprecated';
  last_validated_at: Date;
}

export interface Observation {
  id: string;
  source: string; // Log source
  project: string;
  text: string;
  confidence: 'low' | 'medium' | 'high';
  limit_notes: string;
  promoted_to_rule?: string; // Rule ID if promoted
  created_at: Date;
}
