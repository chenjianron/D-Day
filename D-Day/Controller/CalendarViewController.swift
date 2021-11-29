//
//  CalendarViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/26.
//

import Toolkit
import JTAppleCalendar

class CalendarViewController:UIViewController {
    
    var _selectedCellDate = Date().toDay()
    var previousSelectedCellDate:Date?
    var selectedCellDate:Date{
        set {
            _selectedCellDate = newValue.toDay()
            displayDate()
            setTogetherDays()
        }
        get {
            _selectedCellDate
        }
    }
    
    lazy var showYearAndMonthDate = selectedCellDate.toMonth()
    let noteManager:NoteManager = NoteManager()
    var noteDataSource :[NoteManager.NoteModel]?
    lazy var moodImages:[String] = {
        return ["Mood-1.pdf","Mood-2.pdf","Mood-3.pdf","Mood-4.pdf","Mood-5.pdf"]
    }()
    
    lazy var titleView:CalendarHeadView = {
        let calendarHeadView = CalendarHeadView()
        calendarHeadView.rightBtnClickComplete = { [self] in
            Statistics.event(.CalendarTap, label: "下个月")
            var nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedCellDate )
            var nextMonthDateString = nextMonthDate?.toString4()
            nextMonthDateString! += "-01"
            previousSelectedCellDate = selectedCellDate
            selectedCellDate = (nextMonthDateString?.toDateWithFormat("yyyy-MM-dd"))!
            calendar.scrollToDate(selectedCellDate)
            setUpNoteDataSource()
            calendar.reloadDates([previousSelectedCellDate!,selectedCellDate])
//            calendar.reloadData()
        }
        calendarHeadView.leftBtnClickComplete = { [self] in
            Statistics.event(.CalendarTap, label: "上个月")
            var lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedCellDate)
            var lastMonthDateString = lastMonthDate?.toString4()
            lastMonthDateString! += "-01"
            previousSelectedCellDate = selectedCellDate
            selectedCellDate = (lastMonthDateString?.toDateWithFormat("yyyy-MM-dd"))!
            calendar.scrollToDate(selectedCellDate)
            setUpNoteDataSource()
            calendar.reloadDates([previousSelectedCellDate!,selectedCellDate])
//            calendar.reloadData()
        }
        calendarHeadView.calendarPickerComplete = { [self] in
            Statistics.event(.CalendarTap, label: "月份选择")
            let calendarDatePicker = CalendarDatePickerViewController()
            calendarDatePicker.completion = { [self] date in
                previousSelectedCellDate = selectedCellDate
//                if #available(iOS 13.0, *),!Util.isIPad{
//                    var dateString = date.toString4()
//                    dateString += "-01"
//                    selectedCellDate = (dateString.toDateWithFormat("yyyy-MM-dd"))!
//                } else {
//                    selectedCellDate = date
//                }
                selectedCellDate = date
                calendar.scrollToDate(selectedCellDate)
                setUpNoteDataSource()
                calendar.reloadDates([previousSelectedCellDate!,selectedCellDate])
//                calendar.reloadData()
            }
            calendarDatePicker.modalPresentationStyle = .custom
            navigationController?.present(calendarDatePicker, animated: false)
        }
        calendarHeadView.isUserInteractionEnabled = true
        return calendarHeadView
    }()
    lazy var weekdaysView:WeekdaysView = {
        let view = WeekdaysView()
        return view
    }()
    lazy var calendar:JTACMonthView =  {
        let calendar = JTACMonthView()
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        calendar.scrollDirection = .horizontal
        calendar.backgroundColor = .white
        calendar.showsVerticalScrollIndicator = false
        calendar.showsHorizontalScrollIndicator = false
        calendar.calendarDelegate = self
        calendar.calendarDataSource = self
        calendar.register(CalendarViewCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(CalendarViewCell.self))
        return calendar
    }()
    lazy var lineView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF8F8F8)
        return view
    }()
    lazy var noteHeadView:CalendarNoteHeader = {
        let headView = CalendarNoteHeader()
        headView.addBtnClickComplete = { [self] in
            Statistics.event(.CalendarTap, label: "添加便签")
            let noteEditViewController = NoteEditViewController()
            noteEditViewController.dateString = selectedCellDate.toString3()
            noteEditViewController.textLabel.text = setTimeLable()
            noteEditViewController.modalPresentationStyle = .custom
            noteEditViewController.completion = { selectMoodIndex,contentText in
                noteManager.addNote(date: selectedCellDate.toString3(), selectMoodIndex: selectMoodIndex, contentText: contentText)
                setUpNoteDataSource()
                calendar.reloadDates([selectedCellDate])
            }
            navigationController?.present(noteEditViewController, animated: false, completion: nil)
        }
        if HeadInfoManager.default.loveDate.numberOfDays(to: selectedCellDate) >= 0 {
            headView.timeLabel.text = __("在一起的第") + (HeadInfoManager.default.loveDate.numberOfDays(to: selectedCellDate) + 1).description + __("天")
        }
        return headView
    }()
    lazy var emptyLabel:UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = K.Color.AuxiliaryColor
        label.text = __("目前没有内容\n点击右上角添加")
        return label
    }()
    lazy var noteTableView:UITableView = {
        let tableView = UITableView(frame: .zero,style:.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(NoteTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(NoteTableViewCell.self))
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpUI()
        calendar.scrollToDate(selectedCellDate)
        displayDate()
        setUpNoteDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("日历页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("日历页")
    }
    
}

// MARK: TableView
extension CalendarViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteDataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NoteTableViewCell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(NoteTableViewCell.self),for: indexPath) as! NoteTableViewCell
        cell.selectionStyle = .none
        cell.setData(noteModel: noteDataSource![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Statistics.event(.CalendarTap, label: "便签")
        let noteClickAcitonViewController = NoteClickActionViewController()
        noteClickAcitonViewController.selectedIndex = noteDataSource![indexPath.row].selectMoodIndex
        noteClickAcitonViewController.contentLabel.text = noteDataSource![indexPath.row].contentText
        noteClickAcitonViewController.moodImageView.image = UIImage(named: moodImages[noteDataSource![indexPath.row].selectMoodIndex])
        noteClickAcitonViewController.editCompletion = { [self]
            (selectedMoodImageIndex,contentText) in
            Statistics.event(.CalendarTap, label: "更多-编辑")
            dismiss(animated: false, completion:{
                let noteEditViewController = NoteEditViewController()
                noteEditViewController.dateString = selectedCellDate.toString3()
                noteEditViewController.selectIndex = selectedMoodImageIndex
                noteEditViewController.textLabel.text = setTimeLable()
                noteEditViewController.textField.text = contentText
                noteEditViewController.modalPresentationStyle = .custom
                noteEditViewController.completion = { selectMoodIndex,contentText in
                    noteManager.updateNote(date: selectedCellDate.toString3(),selectMoodIndex: selectMoodIndex, contentText: contentText,tableViewIndex: indexPath.row)
                    setUpNoteDataSource()
                    calendar.reloadDates([selectedCellDate])
                }
                navigationController?.present(noteEditViewController, animated: false, completion: nil)
            })
        }
        noteClickAcitonViewController.deleteCompletion = { [self] in
            Statistics.event(.CalendarTap, label: "更多-删除")
            deleteSecond {
                Statistics.event(.CalendarTap, label: "更多-确认删除")
                noteManager.deleteNote(date: selectedCellDate.toString3(), tableViewIndex: indexPath.row)
                setUpNoteDataSource()
                dismiss(animated: true, completion: nil)
                calendar.reloadDates([selectedCellDate])
            }
        }
        noteClickAcitonViewController.modalPresentationStyle = .custom
        navigationController?.present(noteClickAcitonViewController, animated: false, completion: nil)
    }
}

// MARK: JTACMonthViewDataSource
extension CalendarViewController: JTACMonthViewDataSource {
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        let currentDate = Calendar.current
        formatter.dateFormat = "yyyy MM dd"
        formatter.locale = currentDate.locale
        formatter.timeZone = currentDate.timeZone
        
        let startDate = formatter.date(from: "2000 01 01")!
        let endDate = formatter.date(from: "2100 12 31")!
        let paramters = ConfigurationParameters(startDate: startDate, endDate: endDate,numberOfRows: 6,calendar: currentDate, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        return paramters
    }
}

//MARK: JTACMonthViewDelegate
extension CalendarViewController:JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCalendarCellStyle(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CalendarViewCell.self), for: indexPath) as! CalendarViewCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo){
        guard let startDate = visibleDates.monthDates.first?.date else { return }
        previousSelectedCellDate = selectedCellDate
        selectedCellDate = startDate
        setUpNoteDataSource()
        calendar.reloadDates([previousSelectedCellDate!,selectedCellDate])
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        previousSelectedCellDate = selectedCellDate
        selectedCellDate = cellState.date
        setUpNoteDataSource()
        calendar.reloadDates([previousSelectedCellDate!,selectedCellDate])
//        calendar.reloadData()
    }
}

//MARK: JTACMonthView
extension CalendarViewController {
    
    func configureCalendarCellStyle(view: JTACDayCell?, cellState: CellState){
        guard let cellStyle = view as? CalendarViewCell else { return }
        if cellState.dateBelongsTo == .thisMonth {
            cellStyle.isHidden = false
            cellStyle.dayText.text = cellState.text
            handleCellSelectedStatus(cell: cellStyle, cellState: cellState)
        } else {
            cellStyle.isHidden = true
        }
    }
    
    func handleCellSelectedStatus(cell: CalendarViewCell, cellState:CellState){
        //是否被选择
        if cellState.date.toDay() != selectedCellDate.toDay() {
            cell.dayText.textColor = .black
            cell.selectedBackgroundImageView.isHidden = true
            cell.hasRecordImageView.backgroundColor = K.Color.ThemeColor
        } else {
            cell.dayText.textColor = .white
            cell.selectedBackgroundImageView.isHidden = false
            cell.hasRecordImageView.backgroundColor = .white
        }
        if noteManager.findNote(date: cellState.date.toString3())?.count != 0 {
            cell.hasRecordImageView.isHidden = false
        } else {
            cell.hasRecordImageView.isHidden = true
        }
    }
    
    func setUpViewsOfCalendar(from visibleDates:DateSegmentInfo){
        guard let startDate = visibleDates.monthDates.first?.date else { return }
        showYearAndMonthDate = startDate.toMonth()
    }
}

// - Private
extension CalendarViewController {
    
    func setTimeLable() -> String{
        let currentCalendar = Calendar.current
        let year = currentCalendar.component(.year, from: selectedCellDate)
        let month = currentCalendar.component(.month, from: selectedCellDate)
        return year.description + "." + month.description
    }
    
    func displayDate(){
        titleView.currentMonthLabel.text = setTimeLable()
    }
    
    func setTogetherDays(){
        if HeadInfoManager.default.loveDate.numberOfDays(to: selectedCellDate) >= 0 {
            noteHeadView.timeLabel.text = __("在一起的第") + (HeadInfoManager.default.loveDate.numberOfDays(to: selectedCellDate) + 1).description + __("天")
        } else {
            noteHeadView.timeLabel.text = ""
        }
    }
    
    func setUpNoteDataSource(){
        noteDataSource = noteManager.findNote(date: selectedCellDate.toString3())
        if noteDataSource?.count == 0 {
            emptyLabel.isHidden = false
            noteTableView.isHidden = true
            noteHeadView.addBtn.isHidden = false
        } else {
            if noteDataSource!.count >= 4 {
                noteHeadView.addBtn.isHidden = true
            } else {
                noteHeadView.addBtn.isHidden = false
            }
            emptyLabel.isHidden = true
            noteTableView.isHidden = false
        }
        noteTableView.reloadData()
    }
    
    //删除二次权限
    func deleteSecond(completion: @escaping()->Void){
        let alert = UIAlertController(title: __("删除"), message: __("删除后无法找回\n确认删除该便签吗？"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: __("取消"), style: .cancel) { (action) in
        }
        let delete = UIAlertAction(title: __("删除"), style: .destructive, handler: {_ in completion()})
        alert.addAction(cancel)
        alert.addAction(delete)
        alert.modalPresentationStyle = .overFullScreen
        presentedViewController!.present(alert, animated: true, completion: nil)
    }
    
    @objc override func backItemDidClick(_ sender: UIBarButtonItem) {
        Statistics.event(.CalendarTap, label: "返回")
        self.navigationController?.popViewController(animated: true)
    }
}

// - UI
extension CalendarViewController {
    
    func setUpUI(){
        showBackItem()
        view.backgroundColor = .white
        navigationItem.titleView = titleView
        view.addSubview(weekdaysView)
        view.addSubview(calendar)
        view.addSubview(lineView)
        view.addSubview(noteHeadView)
        view.addSubview(emptyLabel)
        view.addSubview(noteTableView)
        setUpConstraints()
    }
    
    func setUpConstraints(){
        titleView.snp.makeConstraints{ make in
            make.width.equalTo(220)
            make.height.equalTo(37)
            make.center.equalToSuperview()
        }
        weekdaysView.snp.makeConstraints{ make in
            make.height.equalTo(24)
            make.width.equalTo(Util.isIPad ? G.share.w(361): 361)
            make.top.equalTo(safeAreaTop).offset(15)
            make.centerX.equalToSuperview()
        }
        calendar.snp.makeConstraints{ make in
            make.height.equalTo(Util.isIPad ? 423 : 236)
            make.width.equalTo(Util.isIPad ? G.share.w(361) : 361)
            make.top.equalTo(weekdaysView.snp.bottom).offset(G.share.h(17))
            make.centerX.equalToSuperview()
        }
        lineView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(5)
            make.top.equalTo(calendar.snp.bottom).offset(0)
            make.centerX.equalToSuperview()
        }
        noteHeadView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(lineView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints{ make in
            make.top.equalTo(noteHeadView).offset(135)
            make.centerX.equalToSuperview()
        }
        noteTableView.snp.makeConstraints{ make in
            make.top.equalTo(noteHeadView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
            make.centerX.equalToSuperview()
        }
    }
}
