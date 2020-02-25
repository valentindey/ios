//
//  NCDetailNavigationController+Menu.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 07/02/2020.
//  Copyright © 2020 Marino Faggiana All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import FloatingPanel
import NCCommunication

extension NCDetailNavigationController {

    private func initMoreMenu(viewController: UIViewController, metadata: tableMetadata) -> [NCMenuAction] {
        var actions = [NCMenuAction]()
        let fileNameExtension = (metadata.fileNameView as NSString).pathExtension.uppercased()
        let directEditingCreators = NCManageDatabase.sharedInstance.getDirectEditingCreators(account: appDelegate.activeAccount)

        actions.append(
            NCMenuAction(title: NSLocalizedString("_open_in_", comment: ""),
                icon: CCGraphics.changeThemingColorImage(UIImage(named: "openFile"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon),
                action: { menuAction in
                    NCMainCommon.sharedInstance.downloadOpen(metadata: metadata, selector: selectorOpenIn)
                }
            )
        )

        actions.append(
            NCMenuAction(title: NSLocalizedString("_share_", comment: ""),
                icon: CCGraphics.changeThemingColorImage(UIImage(named: "share"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon),
                action: { menuAction in
                    NCMainCommon.sharedInstance.openShare(ViewController: viewController, metadata: metadata, indexPage: 0)
                }
            )
        )
        
        actions.append(
            NCMenuAction(title: NSLocalizedString("_delete_", comment: ""),
                icon: CCGraphics.changeThemingColorImage(UIImage(named: "trash"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon),
                action: { menuAction in
                    
                    let alertController = UIAlertController(title: "", message: NSLocalizedString("_want_delete_", comment: ""), preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("_yes_delete_", comment: ""), style: .default) { (action:UIAlertAction) in
                        
                        if let directory = NCManageDatabase.sharedInstance.getTableDirectory(predicate: NSPredicate(format: "account == %@ AND serverUrl == %@", metadata.account, metadata.serverUrl)) {
                            
                            NCMainCommon.sharedInstance.deleteFile(metadatas: [metadata], e2ee: directory.e2eEncrypted, serverUrl: metadata.serverUrl, folderocId: directory.ocId) { (errorCode, errorMessage) in
                                
                                if errorCode == 0 {
                                    NCMainCommon.sharedInstance.reloadDatasource(ServerUrl: metadata.serverUrl, ocId: metadata.ocId, action: k_action_DEL)
                                    self.appDelegate.activeDetail.viewUnload()
                                } else {
                                    NCContentPresenter.shared.messageNotification("_error_", description: errorMessage, delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: errorCode)
                                }
                            }
                        }
                    })
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("_no_delete_", comment: ""), style: .default) { (action:UIAlertAction) in })
                                        
                    self.present(alertController, animated: true, completion:nil)
                }
            )
        )
        
        if CCUtility.isDocumentModifiableExtension(fileNameExtension) && (directEditingCreators == nil || !appDelegate.reachability.isReachable()) {
            actions.append(
                NCMenuAction(title: NSLocalizedString("_internal_modify_", comment: ""),
                    icon: CCGraphics.changeThemingColorImage(UIImage(named: "pencil"), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon),
                    action: { menuAction in
                        if let navigationController = UIStoryboard(name: "NCText", bundle: nil).instantiateViewController(withIdentifier: "NCText") as? UINavigationController {
                            navigationController.modalPresentationStyle = .pageSheet
                            navigationController.modalTransitionStyle = .crossDissolve
                            if let textViewController = navigationController.topViewController as? NCText {
                                textViewController.metadata = metadata;
                                viewController.present(navigationController, animated: true, completion: nil)
                            }
                        }
                    }
                )
            )
        }
        
        return actions
    }

    @objc func toggleMoreMenu(viewController: UIViewController, metadata: tableMetadata) {
        if appDelegate.activeDetail.subViewActive() != nil {
            let mainMenuViewController = UIStoryboard.init(name: "NCMenu", bundle: nil).instantiateViewController(withIdentifier: "NCMainMenuTableViewController") as! NCMainMenuTableViewController
            mainMenuViewController.actions = self.initMoreMenu(viewController: viewController, metadata: metadata)

            let menuPanelController = NCMenuPanelController()
            menuPanelController.parentPresenter = viewController
            menuPanelController.delegate = mainMenuViewController
            menuPanelController.set(contentViewController: mainMenuViewController)
            menuPanelController.track(scrollView: mainMenuViewController.tableView)

            viewController.present(menuPanelController, animated: true, completion: nil)
        }
    }
}

