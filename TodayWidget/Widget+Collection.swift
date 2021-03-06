//
//  Widget+Collection.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension Widget:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    
    // MARK: - Collection View Data source
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        return max(1, vpns.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if vpns.count == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "addCell",
                for: indexPath
                ) as! AddCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "vpnCell",
                for: indexPath
                ) as! VPNCell
            let vpn = vpns[(indexPath as NSIndexPath).row]
            let selected = VPNManager.sharedManager.selectedVPNID == vpn.ID
            cell.configureWithVPN(vpns[indexPath.row], selected: selected)
            if selected {
                cell.status = VPNManager.sharedManager.status
            } else {
                cell.status = .disconnected
            }
            
            cell.latency = LTPingQueue.sharedQueue
                .latencyForHostname(vpn.server)
            
            return cell
        }
        
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
        ) {
        
        if vpns.count == 0 {
            didTapAdd()
            return
        }
        
        let vpn = vpns[(indexPath as NSIndexPath).row]
        
        VPNManager.sharedManager.selectedVPNID = vpn.ID
        
        if VPNManager.sharedManager.status == .connected {
            if VPNManager.sharedManager.selectedVPNID == vpn.ID {
                // Do not connect it again if tap the same one
                return
            }
        }
        
        var account = vpn.toAccount()
        account.title = vpn.title
        
        VPNManager.sharedManager.saveAndConnect(account)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
        ) -> Bool {
        
        if vpns.count == 0 {
            return true
        }
        
        switch VPNManager.sharedManager.status {
        case .connected, .connecting:
            VPNManager.sharedManager.disconnect()
        default: ()
        }
        return true
        
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
            return cellSize
    }
    
}
