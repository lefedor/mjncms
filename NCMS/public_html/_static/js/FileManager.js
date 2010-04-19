/*
---

authors:
(c) Fedor FL, ffl.public@gmail.com, MIT License.

license: MIT-style

description:
<!-- Here should be CKFINDER File manager, i've even started rewrite connector to perl...
but because fucking demo message [can't they put it into about or smth], I've been forced to write own one. -->

script: FileManager.js

description: Filemanager app

provides: [FileManager, ]

requ_ires: 
- /MooTools [Cookie, URI and may be smth els]
- /Jx.Layout
- /Jx.Panel
- /Jx.Splitter
 
...
*/

var FileManager = new Class({
    
    Implements: Options,
    
    options: {
        connectorUrl: '/content/filemanager_connector',
        connectionEncoding: 'utf-8',
        betweenRequestsTimeout: 600, //for like nginx-protected site limeit req per second, im msecs
        lastPathCookie: 'FmLastDir',
        useLastPathCookie: 1, 
        themesUrl: '/_static/gfx/filemanager_themes',
        theme: 'default',
        theme_icons: Array('ai', 'avi', 'bmp', 'cs', 'dll', 'doc', 'exe', 'fla', 'gif', 'htm', 'html', 'jpg', 'js', 'mdb', 'mp3', 'pdf', 'png', 'ppt', 'rdp', 'swf', 'swt', 'txt', 'vsd', 'xls', 'xml', 'zip'),
        elementId: false, 
        elementIdDefault: 'FileManager',
        filePostFrameName: 'FileManagerPostFrame', //also id
        containerWidth: '100%',
        containerHeight: '600',
        filesTreeWidth: 150, //int px only
        actionsBlockHeight: 80, //int px only
        fileDblClickFunction: function(url){
            //return file to caller editor
            var u = new URI(document.location);
            var f = ''+u.getData('CKEditorFuncNum');
            window.opener.CKEDITOR.tools.callFunction(f, url);
            window.close();
        },
        some: 'else'
    },
    
    path: false,
    
    element: false,
    
    layout: false,
    splitter_vertical: false,
    splitter_horizontal: false,
    layout: false,
    
    fileTreeContainer: false,
    fileListContainer: false,
    actionsContainer: false, 
    
    fileTreePanel: false,
    fileListContainerPanel: false,
    actionsContainerPanel: false,
    
    directoryTreeMenu: false,
    
    createDirectoryForm: false,
    uploadFileForm: false,
    renameFileForm: false,
    
    fileListTable: false,
    
    filePostFrame: false,

    initialize: function(element, options){
        this.setOptions(options);
        
        var elementId = false;
        
        if (typeof element == 'string'){
            if($(element) != null){
                this.element = $(element);
            }
            else {
                alert('FileManager element not found. Abort.');
                return false;
            }
        }
        else if (typeof element == 'object'){
            this.element = element;
        }
        else{
            alert('FileManager element not found. Abort.');
            return false;
        }
        
        elementId = this.options.elementId = this.element.get('id');
        
        if(!this.options.elementId){
            if($(this.options.elementIdDefault) != null){
                this.options.elementIdDefault = this.options.elementIdDefault + '' + randy_by_len(6);
            }
            else{
                if($(this.options.elementIdDefault) != null){
                    alert('Element id is not found, default alredy taken. Abort.');
                    return false;
                }
                else{
                    this.element.get('id', this.options.elementIdDefault);
                    this.options.elementId = this.options.elementIdDefault;
                }
            }
        }
        
        this.element.addClass('splitterBox');
        this.element.FileManager = this;
        
        if($(elementId).FileManager.options.useLastPathCookie){
            this.path = Cookie.read(this.options.lastPathCookie);
            if(!this.path){
                this.path = '/'
            }
        }
        else{
            this.path = '/'
        }
        
        this.layout = new Jx.Layout(this.element, {
            position:'relative',
            width: this.options.containerWidth,
            height: this.options.containerHeight
        }).resize();


        this.splitter_vertical = new Jx.Splitter(this.element, {
            splitInto: 2,
            containerOptions: [{width: parseInt(this.options.filesTreeWidth)}, null]
        });
        
        this.splitter_horizontal = new Jx.Splitter(this.splitter_vertical.elements[1], {
            layout: 'vertical',
            splitInto: 2,
            containerOptions: [null, {height: parseInt(this.options.actionsBlockHeight)}]
        });
        
        this.fileTreeContainer = this.splitter_vertical.elements[0];
        this.fileListContainer = this.splitter_horizontal.elements[0];
        this.actionsContainer = this.splitter_horizontal.elements[1];
        
        this.fileTreeContainer.addClass('FmFileTreeContainer');
        this.fileListContainer.addClass('FmFileListContainer');
        this.actionsContainer.addClass('FmActionsContainer');
        
        this.fileTreePanel = new Jx.Panel({
            label: 'Directory Tree',
            parent: this.fileTreeContainer,
            collapse: false 
        });
        
        this.fileListContainerPanel = new Jx.Panel({
            label: 'Files container',
            parent: this.fileListContainer, 
            collapse: false
        });
        
        this.actionsContainerPanel = new Jx.Panel({
            label: 'Actions container',
            parent: this.actionsContainer, 
            collapse: false, 
            hideTitle: true, 
        });
        
        this.updateFileListRequest(this.path);
        
        this.directoryTreeMenu = new Jx.Tree({
            parent: this.fileTreePanel.content
        });

        setTimeout(function(){$(elementId).FileManager.updateDirecoryTreeRequest('/')}, parseInt($(elementId).FileManager.options.betweenRequestsTimeout));
        
        if($(this.options.filePostFrameName) != null){
            this.filePostFrame = $(this.options.filePostFrameName);
        }
        else{
            this.filePostFrame = new Element('iframe',{
                    'name': this.options.filePostFrameName, 
                    'id': this.options.filePostFrameName, 
                    'styles':{'width':'1px','height':'1px', 'border':0,'position':'absolute','left':'0px','top':'0px','z-index': 0, 'visibility': 'hidden'}, 
                    'scrolling':'no',
                    'frameborder':0,
                    'src':  'javascript:false' 
            });
            this.filePostFrame.inject(this.fileTreePanel.content);
        }
        
        this.filePostFrame.addEvent('load', function(){
            $(elementId).FileManager.catchEventFilePostFrameLoad($(elementId).FileManager.options.elementId);
            return false;
        });
        
        this.setActionsContainerPanelClear();
        
        return this;
    },
    
    setDirectoryTreeLoading: function(elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        $(elementId).FileManager.directoryTreeMenu.clear();
        $(elementId).FileManager.directoryTreeMenu.append(
            new Jx.TreeItem({label: 'Loading...'})
        );
        return false;
    },
    
    updateDirecoryTreeRequest: function(path, elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        $(elementId).FileManager.setDirectoryTreeLoading();
        $(elementId).FileManager.path = path;
        new Request({ 
            url: $(elementId).FileManager.options.connectorUrl, 
            method: 'get', 
            data: {
                filemanager_id: elementId,
                action: 'get_path_directory_tree',
                path: path
            }, 
            onComplete: $(elementId).FileManager.updateDirecoryTree
        }).send();
        return false;
    },
    
    updateDirecoryTree: function(req){
        var req_answer = JSON.decode(req);
        var currentNodes = Array();
        if (req_answer != null && typeof(req_answer)== 'object'){
            if (req_answer.status=='ok'){
                if(!req_answer.filemanager_id){
                    alert('FileManager id is not set');
                }
                if($(req_answer.filemanager_id) == null || !$(req_answer.filemanager_id).FileManager){
                    alert('FileManager obj not resolved');
                }
                
                currentNodes[0] = $(req_answer.filemanager_id).FileManager.directoryTreeMenu;
                currentNodes[0].clear();
                req_answer.data.forEach(function(record){
                    currentNodes[parseInt(record.level)] = new Jx.TreeFolder({
                        label: record.name, 
                        onClick: function(){$(req_answer.filemanager_id).FileManager.updateFileListRequest(record.path)}
                    });
                    currentNodes[parseInt(record.level-1)].append(currentNodes[parseInt(record.level)]);
                });
                
                if(req_answer.message){
                    alert(req_answer.message);
                }
            }
            else if (req_answer.status=='fail'){
                if(req_answer.message){
                    alert(req_answer.message);
                }
            }
        }
        else {alert('Directory tree update fail');}
        return false;
    },
    
    setFileListLoading: function(elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        $(elementId).FileManager.fileListContainerPanel.setContent('Loading...');
        return false;
    },
    
    updateFileListRequest: function(path, elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        
        if($(elementId).FileManager.options.useLastPathCookie){
            Cookie.write($(elementId).FileManager.options.lastPathCookie, path);
        }
        
        $(elementId).FileManager.setFileListLoading();
        new Request({ 
            url: $(elementId).FileManager.options.connectorUrl, 
            method: 'get', 
            data: {
                filemanager_id: elementId,
                action: 'get_path_listing',
                path: path
            }, 
            onComplete: $(elementId).FileManager.updateFileList
        }).send();
        return false;
    },
    
    updateFileList: function(req){
        var req_answer = JSON.decode(req);
        var table;
        var table_tr;
        var table_td;
        var icon;
        var extension;
        var path;
        var rowclass;
        var img;
        
        if (req_answer != null && typeof(req_answer)== 'object'){
            if (req_answer.status=='ok'){
                if(!req_answer.filemanager_id){
                    alert('FileManager id is not set');
                }
                if($(req_answer.filemanager_id) == null || !$(req_answer.filemanager_id).FileManager){
                    alert('FileManager obj not resolved');
                }
                
                table = $(req_answer.filemanager_id).FileManager.getFileListTable();
                
                if(req_answer.path!='/'){
                    req_answer.data.unshift({
                        'name':'..',
                        'type':'du',
                        //'path': req_answer.path.replace(/\w+\/?$/, '')
                        'path': req_answer.path.replace(/[^\/]*\/?$/, '')                       
                    });
                }
                
                $A($(req_answer.filemanager_id).FileManager.fileListTable.getElementsByTagName('td'))[0].set('text', 'File Names [Path: '+req_answer.path+']');
                
                req_answer.data.forEach(function(record){
                    
                    if(rowclass == 'A'){
                        rowclass = 'B';
                    }
                    else{
                        rowclass = 'A';
                    }
                    
                    table_tr = new Element('tr',{ 
                        'class': 'FmFileListTableTrFileRow'+rowclass
                    });
                    table_tr.inject(table);
                    
                    table_td = new Element('td',{ 
                        'styles': (record.type == 'f' && !($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction && typeof($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction) == 'function'))? {}:{'cursor':'pointer'}, 
                        'class': 'FmFileListTableTdFileIcon',
                        'text': ''
                    });
                    table_td.inject(table_tr);
                    
                    icon = 'icons/default.icon.gif';
                    if(record.type == 'd'){
                        icon = 'folder.gif';
                    }
                    if(record.type == 'du'){
                        icon = 'folder.up.gif';
                    }
                    else{
                        extension = record.name.split('.');
                        extension = extension[extension.length - 1];
                        if($A($(req_answer.filemanager_id).FileManager.options.theme_icons).contains(extension)){
                            icon = 'icons/'+extension+'.gif';
                        }
                    }
                    
                    new Element('img',{ 
                        'border': '0',
                        'src': $(req_answer.filemanager_id).FileManager.options.themesUrl+'/'+$(req_answer.filemanager_id).FileManager.options.theme+'/'+icon
                    }).inject(table_td);
                    
                    if(record.type != 'f'){
                        table_td.addEvent('dblclick', function (){
                            $(req_answer.filemanager_id).FileManager.updateFileListRequest(record.path);
                        });
                    }
                    else if ($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction && typeof($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction) == 'function') {
                        table_td.addEvent('dblclick', function (){
                            $(req_answer.filemanager_id).FileManager.options.fileDblClickFunction(record.urlpath);
                        });
                    }
                    
                    table_td = new Element('td',{ 
                        'styles': (record.type == 'f' && !($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction && typeof($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction) == 'function'))? {}:{'cursor':'pointer'}, 
                        'class': 'FmFileListTableTdFileName',
                        'text': record.name+' '
                    })
                    table_td.inject(table_tr);
                    
                    if(record.type != 'f'){
                        table_td.addEvent('dblclick', function (){
                            $(req_answer.filemanager_id).FileManager.updateFileListRequest(record.path);
                        });
                    }
                    else if ($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction && typeof($(req_answer.filemanager_id).FileManager.options.fileDblClickFunction) == 'function') {
                        table_td.addEvent('dblclick', function (){
                            $(req_answer.filemanager_id).FileManager.options.fileDblClickFunction(record.urlpath);
                        });
                    }
                    
                    table_td = new Element('td',{ 
                        'class': 'FmFileListTableTdFileActions',
                        'text': ''
                    });
                    table_td.inject(table_tr);
                    if(record.type != 'du'){
                        if(record.type == 'f'){
                            
                            img = new Element('a',{ 
                                'href': record.urlpath, 
                                'title': 'Direct link'
                            });
                            new Element('img',{ 
                                'border': '0',
                                'src': $(req_answer.filemanager_id).FileManager.options.themesUrl+'/'+$(req_answer.filemanager_id).FileManager.options.theme+'/actions/download.gif'
                            }).inject(img);
                            img.inject(table_td);
                            
                            Element('span',{ 
                                'text': ' '
                            }).inject(table_td);
                        }
                        
                        
                        img = new Element('a',{ 
                            'href': '#',
                            'title': 'Rename entry'
                        });                 
                        new Element('img',{ 
                            'border': '0',
                            'src': $(req_answer.filemanager_id).FileManager.options.themesUrl+'/'+$(req_answer.filemanager_id).FileManager.options.theme+'/actions/rename.gif'
                        }).inject(img);
                        img.inject(table_td);
                        
                        img.addEvent('click', function (){
                            $(req_answer.filemanager_id).FileManager.setActionsShowRenameFileForm(record.path);
                            return false;
                        });
                        
                        Element('span',{ 
                            'text': ' '
                        }).inject(table_td);

                        img = new Element('a',{ 
                            'href': '#',
                            'title': 'Delete entry'
                        });                 
                        new Element('img',{ 
                            'border': '0',
                            'src': $(req_answer.filemanager_id).FileManager.options.themesUrl+'/'+$(req_answer.filemanager_id).FileManager.options.theme+'/actions/delete.gif'
                        }).inject(img);
                        img.inject(table_td);
                        
                        img.addEvent('click', function (){
                            if(confirm('Delete '+((record.type != 'f')? 'directory':'file')+'?')){
                                $(req_answer.filemanager_id).FileManager.deletePathRequest(record.path);
                            }
                            return false;
                        });
                    }
                    else{
                        new Element('span',{ 
                            'text': ' '
                        }).inject(table_td);
                    }
                    
                    Element('td',{ 
                        'class': 'FmFileListTableTdFileSize',
                        'text': (record.type == 'f')? record.size:' '
                    }).inject(table_tr);
                    
                });
                
                $(req_answer.filemanager_id).FileManager.fileListContainerPanel.setContent('');
                table.inject($(req_answer.filemanager_id).FileManager.fileListContainerPanel.content);
                table.removeClass('FmIv');
                
                $(req_answer.filemanager_id).FileManager.path=req_answer.path;
                $(req_answer.filemanager_id).FileManager.getCreateDirectoryForm().path.value=req_answer.path;
                $(req_answer.filemanager_id).FileManager.getFileUploadForm().path.value=req_answer.path;
                $(req_answer.filemanager_id).FileManager.getRenameFileForm().path.value=req_answer.path;
                                
                if(req_answer.message){
                    alert(req_answer.message);
                }
            }
            else if (req_answer.status=='fail'){
                if(req_answer.message){
                    alert(req_answer.message);
                }
            }
        }
        else {alert('File list update fail');}
        return false;
    },
    
    getFileListTable: function(elementId) {
        if(!elementId){
            elementId = this.options.elementId;
        }
        var table;
        var table_tr;
        var table_td;
        if(!$(elementId).FileManager.fileListTable){
            table = new Element('table',{ 
                'class': 'FmFileListTable FmIv'
            });
            table_tr = new Element('tr',{ 
                'class': 'FmFileListTableTrHeaderRow'
            });
            table_tr.inject(table);
            new Element('td',{ 
                'class': 'FmFileListTableTdHeaderName',
                'text': 'File Names', 
                'colspan': 2
            }).inject(table_tr);
            new Element('td',{ 
                'class': 'FmFileListTableTdHeaderActions',
                'text': 'Actions'
            }).inject(table_tr);
            new Element('td',{ 
                'class': 'FmFileListTableTdHeaderSize',
                'text': 'File Size'
            }).inject(table_tr);
            
            $(elementId).FileManager.fileListTable = table;
            
        }

        $A($(elementId).FileManager.fileListTable.getElementsByTagName('tr')).each(function(tr){
            if(!tr.hasClass('FmFileListTableTrHeaderRow')){
                tr.destroy();
            }
        });
        
        return $(elementId).FileManager.fileListTable;
    },
    
    getCreateDirectoryForm: function(elementId) {
        var form;
        if(!elementId){
            elementId = this.options.elementId;
        }
        if(!$(elementId).FileManager.createDirectoryForm){
            form = new Element('form',{ 
                'action': $(elementId).FileManager.options.connectorUrl, 
                'method': 'get', 
                'accept-charset': $(elementId).FileManager.options.connectionEncoding, 
                'class': 'FmOneStringForm FmIv' 
                
            });
            Element('input',{ 
                'type': 'hidden',
                'name': 'action',
                'value': 'create_directory'
            }).inject(form);
            Element('input',{ 
                'type': 'hidden',
                'name': 'path',
                'value': ''
            }).inject(form);
            Element('input',{ 
                'type': 'hidden',
                'name': 'filemanager_id',
                'value': $(elementId).FileManager.options.elementId
            }).inject(form);
            Element('input',{ 
                'type': 'text',
                'name': 'newdir_name',
                'size': 20, 
                'maxlength': 255
            }).inject(form);
            Element('span',{ 
                'text': ' '
            }).inject(form);
            Element('input',{ 
                'type': 'submit',
                'value': 'Create directory'
            }).inject(form);
            
            form.addEvent('submit', function (){
                if(confirm('Create directory?')){
                    //$(elementId).FileManager.getCreateDirectoryForm().submit();
                    new Request({ 
                        url: $(elementId).FileManager.options.connectorUrl, 
                        method: 'get', 
                        data: $(elementId).FileManager.getCreateDirectoryForm(), 
                        onComplete: function(req){
                            var req_answer = JSON.decode(req);
                            if (req_answer != null && typeof(req_answer)== 'object'){
                                if (req_answer.status=='ok'){
                                    if(!req_answer.filemanager_id){
                                        alert('FileManager id is not set');
                                    }
                                    if($(req_answer.filemanager_id) == null || !$(req_answer.filemanager_id).FileManager){
                                        alert('FileManager obj not resolved');
                                    }

                                    $(elementId).FileManager.updateDirecoryTreeRequest('/');
                                    setTimeout(function(){$(elementId).FileManager.updateFileListRequest($(elementId).FileManager.getCreateDirectoryForm().path.value)}, parseInt($(elementId).FileManager.options.betweenRequestsTimeout));
                                    
                                    if(req_answer.message){
                                        alert(req_answer.message);
                                    }
                                }
                                else if (req_answer.status=='fail'){
                                    if(req_answer.message){
                                        alert(req_answer.message);
                                    }
                                }
                            }
                        }
                    }).send();
                    return false;
                }
                return false;
            });
            
            $(elementId).FileManager.createDirectoryForm = form;
            
        }
        return $(elementId).FileManager.createDirectoryForm;
    },
    
    getFileUploadForm: function(elementId) {
        var form;
        if(!elementId){
            elementId = this.options.elementId;
        }
        if(!$(elementId).FileManager.uploadFileForm){
            form = new Element('form',{ 
                'action': $(elementId).FileManager.options.connectorUrl, 
                'method': 'post', 
                'target': $(elementId).FileManager.options.filePostFrameName, 
                'accept-charset': $(elementId).FileManager.options.connectionEncoding, 
                'enctype': 'multipart/form-data', 
                'class': 'FmOneStringForm FmIv' 
                
            });
            Element('input',{ 
                'type': 'hidden',
                'name': 'action',
                'value': 'upload_file'
            }).inject(form);
            Element('input',{ 
                'type': 'hidden',
                'name': 'path',
                'value': ''
            }).inject(form);
            Element('input',{ 
                'type': 'hidden',
                'name': 'filemanager_id',
                'value': $(elementId).FileManager.options.elementId
            }).inject(form);
            Element('input',{ 
                'type': 'file',
                'name': 'clientpc_file',
                'size': 20, 
                'maxlength': 255
            }).inject(form);
            Element('span',{ 
                'text': ' '
            }).inject(form);
            Element('input',{ 
                'type': 'submit',
                'value': 'Upload File'
            }).inject(form);
            
            form.addEvent('submit', function (){
                $(elementId).FileManager.getFileUploadForm().submit();
                return false;
            });
            
            $(elementId).FileManager.uploadFileForm = form;
            
        }
        return $(elementId).FileManager.uploadFileForm;
    },
    
    getRenameFileForm: function(elementId) {
        var form;
        if(!elementId){
            elementId = this.options.elementId;
        }
        if(!$(elementId).FileManager.renameFileForm){
            form = new Element('form',{ 
                'action': $(elementId).FileManager.options.connectorUrl, 
                'method': 'get', 
                'accept-charset': $(elementId).FileManager.options.connectionEncoding, 
                'class': 'FmOneStringForm FmIv' 
                
            });
            Element('input',{ 
                'type': 'hidden',
                'name': 'action',
                'value': 'rename_path'
            }).inject(form);
            Element('input',{ 
                'type': 'hidden',
                'name': 'path',
                'value': ''
            }).inject(form);
            Element('input',{ 
                'type': 'hidden',
                'name': 'filemanager_id',
                'value': $(elementId).FileManager.options.elementId
            }).inject(form);
            Element('span',{ 
                'text': 'Old name: '
            }).inject(form);
            Element('input',{ 
                'type': 'text',
                'name': 'old_name',
                'readonly': 'readonly',
                'size': 20, 
                'maxlength': 255
            }).inject(form);
            Element('span',{ 
                'text': ', New name: '
            }).inject(form);
            Element('input',{ 
                'type': 'text',
                'name': 'new_name',
                'size': 20, 
                'maxlength': 255
            }).inject(form);
            Element('span',{ 
                'text': ' '
            }).inject(form);
            Element('input',{ 
                'type': 'submit',
                'value': 'Rename entry'
            }).inject(form);
            
            form.addEvent('submit', function (){
                if(confirm('Rename entry?')){
                    new Request({ 
                        url: $(elementId).FileManager.options.connectorUrl, 
                        method: 'get', 
                        data: $(elementId).FileManager.getRenameFileForm(), 
                        onComplete: function(req){
                            var req_answer = JSON.decode(req);
                            if (req_answer != null && typeof(req_answer)== 'object'){
                                if (req_answer.status=='ok'){
                                    if(!req_answer.filemanager_id){
                                        alert('FileManager id is not set');
                                    }
                                    if($(req_answer.filemanager_id) == null || !$(req_answer.filemanager_id).FileManager){
                                        alert('FileManager obj not resolved');
                                    }

                                    $(elementId).FileManager.updateDirecoryTreeRequest('/');
                                    setTimeout(function(){$(elementId).FileManager.updateFileListRequest($(elementId).FileManager.getCreateDirectoryForm().path.value)}, parseInt($(elementId).FileManager.options.betweenRequestsTimeout));
                                    
                                    if(req_answer.message){
                                        alert(req_answer.message);
                                    }
                                }
                                else if (req_answer.status=='fail'){
                                    if(req_answer.message){
                                        alert(req_answer.message);
                                    }
                                }
                            }
                        }
                    }).send();
                    return false;
                }
                return false;
            });
            
            $(elementId).FileManager.renameFileForm = form;
            
        }
        return $(elementId).FileManager.renameFileForm;
    },
    
    setActionsContainerPanelClear: function (elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        var href;
                
        $(elementId).FileManager.actionsContainerPanel.setContent('');
        
        Element('span',{ 
            'text': ' '
        }).inject($(elementId).FileManager.actionsContainerPanel.content);
        
        href = new Element('a',{ 
            'href': '#',
            'text': 'Create directory'
        });
        href.addEvent('click', function (){
            $(elementId).FileManager.setActionsCreateDirectory();
            return false;
        });
        href.inject($(elementId).FileManager.actionsContainerPanel.content);

        Element('span',{ 
            'text': ' | '
        }).inject($(elementId).FileManager.actionsContainerPanel.content);
        
        href = new Element('a',{ 
            'href': '#',
            'text': 'Upload file'
        });
        href.addEvent('click', function (){
            $(elementId).FileManager.setActionsFileUpload();
            return false;
        });
        href.inject($(elementId).FileManager.actionsContainerPanel.content);

        Element('br').inject($(elementId).FileManager.actionsContainerPanel.content);
        Element('br').inject($(elementId).FileManager.actionsContainerPanel.content);
        
        $(elementId).FileManager.getFileUploadForm().addClass('FmIv');
        $(elementId).FileManager.getCreateDirectoryForm().addClass('FmIv');
        
        return false;
    },
    
    setActionsCreateDirectory:function(elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        
        $(elementId).FileManager.getFileUploadForm().addClass('FmIv');
        $(elementId).FileManager.getRenameFileForm().addClass('FmIv');
        
        var form = $(elementId).FileManager.getCreateDirectoryForm();
        form.inject($(elementId).FileManager.actionsContainerPanel.content);
        form.removeClass('FmIv');
    },
    
    setActionsFileUpload:function(elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        
        $(elementId).FileManager.getCreateDirectoryForm().addClass('FmIv');
        $(elementId).FileManager.getRenameFileForm().addClass('FmIv');
        
        var form = $(elementId).FileManager.getFileUploadForm();
        form.inject($(elementId).FileManager.actionsContainerPanel.content);
        form.removeClass('FmIv');
    },
    
    setActionsShowRenameFileForm: function(path, elementId) {
        if(!elementId){
            elementId = this.options.elementId;
        }
        
        $(elementId).FileManager.getCreateDirectoryForm().addClass('FmIv');
        $(elementId).FileManager.getFileUploadForm().addClass('FmIv');
        
        var form = $(elementId).FileManager.getRenameFileForm();
        
        form.path.value=path.replace(/[^\/]*\/?$/, '');
        form.old_name.value=path.replace(/^.*?([^\/]*)?\/?$/, '$1');
        form.new_name.value=path.replace(/^.*?([^\/]*)?\/?$/, '$1');
        form.inject($(elementId).FileManager.actionsContainerPanel.content);
        form.removeClass('FmIv');
        
    },
    
    catchEventFilePostFrameLoad:function(elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        var req = window.frames[$(elementId).FileManager.filePostFrame.get('name')].document.title;
        if(!req){
            //alert('Frame loaded without reply');
            return false;
        }
        
        var req_answer = JSON.decode(req);
        if (req_answer != null && typeof(req_answer)== 'object'){
            if (req_answer.status=='ok'){
                if(!req_answer.filemanager_id){
                    alert('FileManager id is not set');
                }
                if($(req_answer.filemanager_id) == null || !$(req_answer.filemanager_id).FileManager){
                    alert('FileManager obj not resolved');
                }
                
                $(elementId).FileManager.updateDirecoryTreeRequest('/');
                setTimeout(function(){$(elementId).FileManager.updateFileListRequest(req_answer.path)}, parseInt($(elementId).FileManager.options.betweenRequestsTimeout));
                
                if(req_answer.message){
                    alert(req_answer.message);
                }
            }
            else if (req_answer.status=='fail'){
                if(req_answer.message){
                    alert(req_answer.message);
                }
            }
        }
        else{alert('Frame still loaded without reply');}
        return false;
    },
    
    deletePathRequest: function(path, elementId){
        if(!elementId){
            elementId = this.options.elementId;
        }
        
        new Request({ 
            url: $(elementId).FileManager.options.connectorUrl, 
            method: 'get', 
            data: {
                filemanager_id: elementId,
                action: 'delete_path',
                rm_file: path.replace(/^.*?([^\/]*)?\/?$/, '$1'), 
                path: path.replace(/[^\/]*\/?$/, '')
            }, 
            onComplete: function(req){
                var req_answer = JSON.decode(req);
                if (req_answer != null && typeof(req_answer)== 'object'){
                    if (req_answer.status=='ok'){
                        if(!req_answer.filemanager_id){
                            alert('FileManager id is not set');
                        }
                        if($(req_answer.filemanager_id) == null || !$(req_answer.filemanager_id).FileManager){
                            alert('FileManager obj not resolved');
                        }

                        $(elementId).FileManager.updateDirecoryTreeRequest('/');
                        setTimeout(function(){$(elementId).FileManager.updateFileListRequest(path.replace(/[^\/]*\/?$/, ''))}, parseInt($(elementId).FileManager.options.betweenRequestsTimeout));//path.replace(/\w+\/?$/, ''));
                        
                        if(req_answer.message){
                            alert(req_answer.message);
                        }
                    }
                    else if (req_answer.status=='fail'){
                        if(req_answer.message){
                            alert(req_answer.message);
                        }
                    }
                }
            }
        }).send();
    },
    
    returnFalse: function() {
        //last entry - no comma after } !
        return false;
    }
    
});
