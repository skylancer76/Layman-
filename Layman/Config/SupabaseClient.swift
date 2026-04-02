//
//  SupabaseClient.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Supabase
import Foundation

let supabase = SupabaseClient(
    supabaseURL: URL(string: Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? "")!,
    supabaseKey: Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
)
