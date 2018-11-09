//
//  PersistenceLayer.swift
//  Habitual
//
//  Created by Erick Sanchez on 11/8/18.
//  Copyright © 2018 Sam Galizia. All rights reserved.
//

import Foundation

struct PersistenceLayer {
    
    // MARK: - VARS
    
    private(set) var habits: [Habit] = []
    
    private static let userDefaultsHabitsKeyValue = "HABITS_ARRAY"
    
    init() {
        self.loadHabits()
    }
    
    // MARK: - RETURN VALUES
    
    //add new habit
    mutating func createNewHabit(name: String, image: Habit.Images) -> Habit {
        let newHabit = Habit(title: name, image: image)
        self.habits.insert(newHabit, at: 0)
        self.saveHabits()
        
        return newHabit
    }
    
    // MARK: - METHODS
    
    //mark habit complete
    mutating func markHabitAsCompleted(_ habitIndex: Int) {
        var updatedHabit = self.habits[habitIndex]
        
        //update completion count
        updatedHabit.numberOfCompletions += 1
        
        //update current streak
        if let lastCompletionDate = updatedHabit.lastCompletionDate, lastCompletionDate.isYesterday {
            updatedHabit.currentStreak += 1
        } else {
            updatedHabit.currentStreak = 0
        }
        
        //update best streak
        if updatedHabit.currentStreak > updatedHabit.bestStreak {
            updatedHabit.bestStreak = updatedHabit.currentStreak
        }
        
        //update last completion date
        let now = Date()
        updatedHabit.lastCompletionDate = now
            
        self.habits[habitIndex] = updatedHabit
        self.saveHabits()
    }
    
    //delete habit
    mutating func delete(_ habitIndex: Int) {
        self.habits.remove(at: habitIndex)
        self.saveHabits()
    }
    
    //load
    private mutating func loadHabits() {
        let userDefaults = UserDefaults.standard
        guard
            let habitData = userDefaults.data(forKey: PersistenceLayer.userDefaultsHabitsKeyValue),
            let habits = try? JSONDecoder().decode([Habit].self, from: habitData) else {
                return
        }
        
        self.habits = habits
    }
    
    //save
    private func saveHabits() {
        guard let habitsData = try? JSONEncoder().encode(self.habits) else {
            fatalError("could not encode list of habits")
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(habitsData, forKey: PersistenceLayer.userDefaultsHabitsKeyValue)
        userDefaults.synchronize()
    }
}
