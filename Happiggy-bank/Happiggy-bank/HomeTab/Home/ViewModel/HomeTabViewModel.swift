//
//  HomeTabViewModel.swift
//  Happiggy-bank
//
//  Created by 권은빈 on 2022/12/26.
//

import CoreData
// TODO: ViewModel에 UIKit 제거
import UIKit

final class HomeTabViewModel {
    
    // MARK: - Properties
    
    /// fetchedResultsController
    var fetchedResultsController: NSFetchedResultsController<Bottle>?
    
    /// 현재 저금통
    var bottle: Bottle?
    
    /// 현재 진행중인 저금통이 있는지 없는지에 대한 불리언 값
    var hasBottle: Bool {
        self.bottle != nil
    }
    
    /// 오늘이 개봉날인지 아닌지에 대한 불리언 값
    var isTodayEndDate: Bool {
        let today = Calendar.current.startOfDay(for: Date()).customFormatted(type: .dot)
        let endDate = self.bottle?.endDate.customFormatted(type: .dot)
        
        return today == endDate
    }
    
    /// 개봉날이 지났는지 아닌지에 대한 불리언 값
    var isEndDatePassed: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        guard let endDate = self.bottle?.endDate
        else { return false }
        
        return today > endDate
    }
    
    /// 쪽지가 있는지 없는지에 대한 불리언 값
    var hasNotes: Bool {
        guard let note = self.bottle?.notes
        else { return false }
        
        return !note.isEmpty
    }
    
    
    init() {
        configureFetchedResultsController()
    }
    
    /// 현재 진행중인 저금통의 D-day 계산
    func dDay() -> String? {
        guard let endDate = bottle?.endDate
        else { return nil }
        let startDate = Date()
        let daysCount = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: startDate),
            to: Calendar.current.startOfDay(for: endDate)
        )
        guard let days = daysCount.day
        else { return nil }
        
        if days >= 0 {
            return "D-\(days)"
        } else {
            return "D+\(days)"
        }
    }
    
    /// fetchedResultsController를 설정
    private func configureFetchedResultsController() {
        let request = Bottle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            key: "startDate_",
            ascending: false
        )]
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceStore.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try self.fetchedResultsController?.performFetch()
            let result = self.fetchedResultsController?.fetchedObjects
            self.bottle = result?.first
        } catch {
            
            // TODO: Alert Error
            print(error.localizedDescription)
        }
    }
    
    /// 저금통의 현재 상태 스냅샷 생성
    func takeBottleSnapshot(inContainerView containerView: UIView) -> UIImage {
        
        let snapshotSize = Metric.snapshotSize(forView: containerView)
        
        /// 이미지 생성
        let renderer = UIGraphicsImageRenderer(size: containerView.bounds.size)
        let image = renderer.image { _ in
            containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        }
        
        /// 리사이징
        let resizedImageRenderer = UIGraphicsImageRenderer(size: snapshotSize)
        let resizedImage = resizedImageRenderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: snapshotSize))
        }
        
        return resizedImage
    }
    
}

extension HomeTabViewModel {
    
    /// 상수값
    enum Metric {
        
        /// 저금통 스냅샷 사이즈
        static func snapshotSize(forView containerView: UIView) -> CGSize {
            let bottleListWidth = UIScreen.main.bounds.width
            let snapshotWidth = (bottleListWidth - 3 * interSnapshotSpacingInBottleList) / 2
            let scale = snapshotWidth / containerView.frame.width
            let snapShotheight = containerView.frame.height * scale
            
            return CGSize(width: snapshotWidth, height: snapShotheight)
        }
        
        /// 저금통 리스트에서 스냅샷 간 간격
        private static let interSnapshotSpacingInBottleList: CGFloat = 24
    }
}