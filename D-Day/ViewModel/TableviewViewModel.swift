//
//  ItemsViewModel.swift
//  D-Day
//
//  Created by GC on 2021/10/18.
//

import Foundation

class TableviewViewModel {
    
    var items:[AnniversaryModel] = []
    
    private let aniversariesManager:LoveAnniversariesManager
    
    init(dataManager:LoveAnniversariesManager) {
        self.aniversariesManager = dataManager
    }
    
    func loadData(completion: @escaping(_ data:[AnniversaryModel])->Void){
        items = aniversariesManager.getAllAnniversary()
//        items = []
        completion(items)
    }
}

// MARK: - 选择或者取消置顶
extension TableviewViewModel {
    
    func setTopAnniversary(_ anniversary:AnniversaryModel,completion: @escaping(_ data:[AnniversaryModel])->Void){
        items = aniversariesManager.setTopAnniversary(anniversary)
        completion(items)
    }
}

// MARK: - 增删改查
extension TableviewViewModel {
    
    func fetchLoveAnniversariesItems(completion: @escaping()->Void ){
        
    }
    
    func removeLoveAniversaryItem(_ anniversary:AnniversaryModel,completion: @escaping(_ data:[AnniversaryModel])->Void){
        items = aniversariesManager.removeAnniversaryItem(anniversary)
        completion(items)
    }
    
    func addLoveAniversaryItem(_ anniversary:AnniversaryModel,completion: @escaping(_ data:[AnniversaryModel])->Void){
        items = aniversariesManager.addAnniversaryItem(anniversary)
        completion(items)
    }
    
    func editLoveAniversaryItem(_ anniversary:AnniversaryModel,completion: @escaping(_ data:[AnniversaryModel])->Void){
        items = aniversariesManager.updateAnniversaryItem(anniversary)
        completion(items)
    }
}
