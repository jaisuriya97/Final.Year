App = {
    web3Provider: null,
    contracts: {},
    account: '0x0',

    init: function () {
        return App.initWeb3();
    },

    initWeb3: function () {
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            web3 = new Web3(window.ethereum);
            try {
                window.ethereum.enable().then(function () {
                    web3.eth.sendTransaction({ /* ... */ });
                });
            } catch (error) {
                console.error("User denied account access")
            }
        }
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
            web3 = new Web3(window.web3.currentProvider);
            web3.eth.sendTransaction({ /* ... */ });
        }
        else {
            console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
        }
        return App.initContract();
    },

    initContract: function () {
        $.getJSON("TenderAllocator.json", function (data) {
            App.contracts.TenderAllocator = TruffleContract(data);
            App.contracts.TenderAllocator.setProvider(App.web3Provider);

            App.render();
        });
    },

    render: function () {
        var tenderAllocatorInstance;
        var loader = $("#loader");
        var content = $("#content");
        loader.show();
        content.hide();
        web3.eth.getCoinbase(function (err, account) {
            if (err === null) {
                App.account = account;
                $("#accountAddress").html("Your Account: " + account);
            }
        });
        content.show()
        loader.hide()
        App.contracts.TenderAllocator.deployed().then(function (instance) {
            tenderAllocatorInstance = instance;
            return Promise.all([
                tenderAllocatorInstance.getTenderNames(),
                tenderAllocatorInstance.getTenderAmounts(),
                tenderAllocatorInstance.getTenderIssuers()
            ]);
        }).then(function (results) {
            console.log(results);
            var names = results[0];
            var amounts = results[1];
            var issuers = results[2];
            console.log(names)
            var tableBody = document.getElementById("tendersResults");
        
            for (var i = 0; i < names.length; i++) {
                var row = tableBody.insertRow(i);
                var indexCell = row.insertCell(0);
                var nameCell = row.insertCell(1);
                var amountCell = row.insertCell(2);
                var issuerCell = row.insertCell(3);
        
                indexCell.innerHTML = i + 1;
                nameCell.innerHTML = names[i];
                amountCell.innerHTML = amounts[i];
                issuerCell.innerHTML = issuers[i];
            }
        
            loader.hide();
            content.style.display = "block";
        }).catch(function (error) {
            console.warn(error);
        });
        
        
    },

    addTender: function () {
        var tenderName = $('#tenderName').val();
        var tenderAmount = $('#tenderAmount').val();
        var tenderID = $('#tenderID').val();
        App.contracts.TenderAllocator.deployed().then(function (instance) {
            return instance.addTender(tenderID,tenderName, tenderAmount, { from: App.account });
        }).then(function (result) {
            window.location.reload();
            console.log("Done");
            App.render;
        }).catch(function (err) {
            console.error(err);
        });
    },

    registerUser: function () {
        console.log("Clocked");
        var name = $('#name').val();
        var email = $('#email').val();
        var phoneNumber = $('#phoneNumber').val();
        App.contracts.TenderAllocator.deployed().then(function(instance){
            console.log("'" + App.account + "'");
            return instance.registerUser(name,email,phoneNumber,{from:App.account});
        }).then(function(result){
            console.log("Done");
            // var userform = $("#userform");
            // var  tenderform = $("#tenderform");
            // userform.hide();
            // tenderform.show();
        }).catch(function(err){
            console.log(err);
        })
       
    }
};

$(function () {
    $(window).load(function () {
        App.init();
    });
});
